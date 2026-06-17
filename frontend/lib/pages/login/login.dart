import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:frontend/services/google_auth_service.dart';
import 'package:http/http.dart' as http;

import 'register.dart';
import '../main_shell.dart';
import '../../services/app_config.dart';
import '../../services/api_services.dart';
import '../../utils/app_responsive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$');

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  String get _authBaseUrl => AppConfig.mobileAuthBaseUrl;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _generalError = null;
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    var hasError = false;

    if (email.isEmpty) {
      _emailError = 'Email is required';
      hasError = true;
    } else if (!_emailRegex.hasMatch(email)) {
      _emailError = 'Email must use the @gmail.com domain';
      hasError = true;
    }

    if (password.isEmpty) {
      _passwordError = 'Password is required';
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
      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/login'),
            headers: {'Accept': 'application/json'},
            body: {'email': email, 'password': password},
          )
          .timeout(const Duration(seconds: 10));

      final Map<String, dynamic>? data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : null;

      if (!mounted) return;

      if (response.statusCode == 200) {
        final token = data?['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await ApiService.saveToken(token);
        }

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
        return;
      }

      final backendMessage =
          data?['message']?.toString() ?? 'Email or password is incorrect';

      if (response.statusCode == 401) {
        setState(() {
          _emailError = 'Email or password incorrect';
          _passwordError = 'Email or password incorrect';
          _generalError = backendMessage;
        });
      } else if (response.statusCode == 422) {
        final errors = data?['errors'];
        setState(() {
          _emailError = _extractFirstError(errors, 'email');
          _passwordError = _extractFirstError(errors, 'password');
          _generalError = _extractAnyError(errors) ?? backendMessage;
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
            'The login request timed out. Check your backend connection.';
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

    // Clear semua error
    setState(() {
      _generalError = null;
      _emailError = null;
      _passwordError = null;
    });

    // Google Sign-In
    final result = await GoogleAuthService.signInWithGoogle();

    // Kalo cancel, balik
    if (result.wasCancelled) return;

    if (result.isSuccess) {
      // Pastiin widget masih mounted sebelum navigate
      if (!mounted) return;

      // Navigate ke home, hapus semua route sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
      // Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      if (!mounted) return;

      setState(() {
        _generalError = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = AppResponsive.isTablet(context);
    final isDesktop = AppResponsive.isDesktop(context);
    final panelTopSpacing =
        screenHeight *
        (isDesktop
            ? 0.18
            : isTablet
            ? 0.22
            : 0.25);
    final panelMaxWidth = AppResponsive.contentMaxWidth(
      context,
      mobile: 420,
      tablet: 520,
      desktop: 560,
    );
    final panelPadding = isDesktop
        ? 36.0
        : isTablet
        ? 32.0
        : 28.0;
    final logoShellSize = isDesktop
        ? 138.0
        : isTablet
        ? 130.0
        : 122.0;
    final logoShellPadding = isDesktop ? 18.0 : 16.0;
    final titleFontSize = isDesktop
        ? 24.0
        : isTablet
        ? 23.0
        : 22.0;
    final actionFontSize = isDesktop ? 19.0 : 18.0;

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
                  constraints: BoxConstraints(maxWidth: panelMaxWidth),
                  child: Container(
                    width: screenWidth,
                    constraints: BoxConstraints(
                      minHeight: screenHeight - panelTopSpacing,
                    ),
                    padding: EdgeInsets.fromLTRB(
                      panelPadding,
                      isDesktop ? 90 : 82,
                      panelPadding,
                      panelPadding,
                    ),
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
                              width: logoShellSize,
                              height: logoShellSize,
                              decoration: const BoxDecoration(
                                color: Color(0xE6FFFFFF),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(logoShellPadding),
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
                            Text(
                              'Welcome Back!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleFontSize,
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
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                _passwordFocusNode.requestFocus();
                              },
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 18),
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              hintText: 'Enter your valid password',
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isSubmitting) {
                                  _handleSignIn();
                                }
                              },
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
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.showAppSnackBar(
                                    'Forgot password is not available yet',
                                    isError: true,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF3F83F8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            if (_generalError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _generalError!,
                                style: const TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _handleSignIn,
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
                                    : Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: actionFontSize,
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
                                  Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      color: Color(0xFF25324B),
                                      fontSize: actionFontSize,
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
                                  'Don\'t have an account ? ',
                                  style: TextStyle(
                                    color: Color(0xFF25324B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign Up',
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
    FocusNode? focusNode,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onSubmitted: onSubmitted,
            inputFormatters: keyboardType == TextInputType.emailAddress
                ? [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9@._%+\-]'),
                    ),
                  ]
                : null,
            onChanged: (_) {
              if (_emailError != null ||
                  _passwordError != null ||
                  _generalError != null) {
                setState(() {
                  _emailError = null;
                  _passwordError = null;
                  _generalError = null;
                });
              }
            },
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
