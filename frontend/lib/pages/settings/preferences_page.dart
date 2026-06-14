import 'package:flutter/material.dart';
import 'package:frontend/pages/settings/notification_settings_page.dart';
import '../../widgets/settings/settings_group.dart';
import '../../widgets/settings/settings_section_title.dart';
import 'profile_privacy_page.dart';
import 'privacy_policy_page.dart';
import 'terms_conditions_page.dart';
import 'about_us_page.dart';
import 'account_information_page.dart';
import 'password_security_page.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 90,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionTitle(
              title: 'ACCOUNT & SECURITY',
            ),
            const SizedBox(height: 12),
            SettingsGroup(
              items: [
                SettingsGroupItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Account Information',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountInformationPage(),
                      ),
                    );
                  },
                ),
                SettingsGroupItem(
                  icon: Icons.shield_outlined,
                  label: 'Password & Security',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordSecurityPage(),
                      ),
                    );
                  },
                ),
                SettingsGroupItem(
                  icon: Icons.visibility_off_outlined,
                  label: 'Profile Privacy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePrivacyPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SettingsSectionTitle(
              title: 'PREFERENCES',
            ),
            const SizedBox(height: 12),
            SettingsGroup(
              items: [
                SettingsGroupItem(
                  icon: Icons.payments_outlined,
                  label: 'Currency',
                  trailing: const Text(
                    'IDR (Rp)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SettingsGroupItem(
                  icon: Icons.language_rounded,
                  label: 'Language',
                  trailing: const Text(
                    'English',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SettingsGroupItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notification Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SettingsSectionTitle(
              title: 'INFORMATION',
            ),
            const SizedBox(height: 12),
            SettingsGroup(
              items: [
                SettingsGroupItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsPage(),
                      ),
                    );
                  },
                ),
                SettingsGroupItem(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsConditionsPage(),
                      ),
                    );
                  },
                ),
                SettingsGroupItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                SettingsGroupItem(
                  icon: Icons.terminal_rounded,
                  label: 'App Version',
                  trailing: const Text(
                    'v1.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'SECURE ENCRYPTION ENABLED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}