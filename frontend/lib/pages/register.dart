import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'home_page.dart';
import 'login.dart';
import '../services/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$');
  final _phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  String get _authBaseUrl => AppConfig.mobileAuthBaseUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    var hasError = false;

    if (email.isEmpty) {
      _emailError = 'Email is required';
      hasError = true;
    } else if (!_emailRegex.hasMatch(email)) {
      _emailError = 'Email must use the @gmail.com domain';
      hasError = true;
    }

    if (phone.isEmpty) {
      _phoneError = 'Phone Number is required';
      hasError = true;
    } else if (!_phoneRegex.hasMatch(phone)) {
      _phoneError = 'Use a valid international phone number e.g +62...';
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Password is required';
      hasError = true;
    } else if (password.isNotEmpty && password != confirmPassword) {
      _passwordError = 'Password doesn\'t match';
      _confirmPasswordError = 'Password doesn\'t match';
      hasError = true;
    }

    if (hasError) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final registerResponse = await http.post(
        Uri.parse('$_authBaseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'username': _buildUsername(email),
          'email': email,
          'phone': phone,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      final Map<String, dynamic>? registerData =
          registerResponse.body.isNotEmpty
          ? jsonDecode(registerResponse.body) as Map<String, dynamic>
          : null;

      if (!mounted) return;

      if (registerResponse.statusCode == 201) {
        final loginResponse = await http.post(
          Uri.parse('$_authBaseUrl/login'),
          headers: {'Accept': 'application/json'},
          body: {'email': email, 'password': password},
        ).timeout(const Duration(seconds: 10));

        if (!mounted) return;

        if (loginResponse.statusCode == 200) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
          return;
        }

        setState(() {
          _generalError =
              'Registration succeeded, but automatic login failed. Please sign in manually.';
        });
        return;
      }

      final backendMessage =
          registerData?['message']?.toString() ?? 'Sign up failed';

      if (registerResponse.statusCode == 422) {
        final errors = registerData?['errors'];
        setState(() {
          _emailError = _extractFirstError(errors, 'email') ?? _emailError;
          _phoneError = _extractFirstError(errors, 'phone') ?? _phoneError;
          _passwordError =
              _extractFirstError(errors, 'password') ?? _passwordError;
          _generalError =
              _extractAnyError(errors) ??
              backendMessage;
        });
      } else {
        setState(() {
          _generalError = backendMessage;
        });
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _generalError =
            'The sign up request timed out. Check your backend connection.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _generalError =
            'Unable to connect to the server. Make sure the backend is running.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _buildUsername(String email) {
    final emailPrefix = email.split('@').first.trim().toLowerCase();
    final sanitized = emailPrefix.replaceAll(RegExp(r'[^a-z0-9._-]'), '');

    if (sanitized.isNotEmpty) {
      return sanitized;
    }

    return 'user${DateTime.now().millisecondsSinceEpoch}';
  }

  String? _extractFirstError(dynamic errors, String field) {
    if (errors is Map<String, dynamic> && errors[field] is List) {
      final fieldErrors = errors[field] as List<dynamic>;
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.first.toString();
      }
    }
    return null;
  }

  String? _extractAnyError(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
      }
    }
    return null;
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    setState(() {
      _generalError = 'Google sign-up is currently unavailable.';
    });
  }

  void _clearErrors() {
    if (_emailError != null ||
        _phoneError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _generalError != null) {
      setState(() {
        _emailError = null;
        _phoneError = null;
        _passwordError = null;
        _confirmPasswordError = null;
        _generalError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelTopSpacing = screenHeight * 0.25;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight,
              child: Image.asset(
                'assets/images/LogResBG.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(82),
                    Colors.white.withAlpha(214),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: panelTopSpacing),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: screenHeight - panelTopSpacing,
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 82, 28, 28),
                    decoration: BoxDecoration(
                      color: const Color(0xE6FFFFFF),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(18),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -34,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 140,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xE6FFFFFF),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -140,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 122,
                              height: 122,
                              decoration: const BoxDecoration(
                                color: Color(0xE6FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Create Your Account!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF25324B),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 18),
                            _buildLabel('Phone Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _phoneController,
                              hintText: 'Enter your phone number ex: +62...',
                              keyboardType: TextInputType.phone,
                              errorText: _phoneError,
                            ),
                            const SizedBox(height: 18),
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Enter your valid password',
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF3F83F8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Re-Enter your valid password',
                              obscureText: _obscureConfirmPassword,
                              errorText: _confirmPasswordError,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF3F83F8),
                                ),
                              ),
                            ),
                            if (_generalError != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _generalError!,
                                style: const TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3F83F8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFF8BB1FB),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: Color(0xFF7C8AA5),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFF8BB1FB),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                                side: const BorderSide(
                                  color: Color(0xFFAAB5CA),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/Google.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Sign up with Google',
                                    style: TextStyle(
                                      color: Color(0xFF25324B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account ? ',
                                  style: TextStyle(
                                    color: Color(0xFF25324B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Color(0xFF3F83F8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF1F2A44),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: keyboardType == TextInputType.emailAddress
                ? [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9@._%+\-]'),
                    ),
                  ]
                : keyboardType == TextInputType.phone
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;
                      if (text.isEmpty) {
                        return newValue;
                      }

                      final plusCount = '+'.allMatches(text).length;
                      final hasLeadingPlus = text.startsWith('+');

                      if (plusCount > 1 ||
                          (plusCount == 1 && !hasLeadingPlus)) {
                        return oldValue;
                      }

                      final digitCount = text
                          .replaceAll(RegExp(r'\D'), '')
                          .length;
                      if (digitCount > 15) {
                        return oldValue;
                      }

                      return newValue;
                    }),
                  ]
                : null,
            onChanged: (_) => _clearErrors(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFACB6C8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: errorText == null
                      ? const Color(0xFFB8C5DB)
                      : const Color(0xFFFF4D4F),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  width: 1.2,
                  color: errorText == null
                      ? const Color(0xFF3F83F8)
                      : const Color(0xFFFF4D4F),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            '*$errorText',
            style: const TextStyle(
              color: Color(0xFFFF4D4F),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
