import 'package:flutter/material.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/services/api_services.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xFFEF4444),
                    ),
                  )
                : const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
            const SizedBox(width: 10),
            Text(
              _isSubmitting ? 'Logging out...' : 'Logout Account',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    Navigator.pop(dialogContext);
                    await _handleLogout(context);
                  },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.logout();
    } catch (_) {
      await ApiService.clearToken();
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
