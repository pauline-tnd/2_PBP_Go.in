import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'preferences_page.dart';
import 'help_centre_page.dart';
import 'contact_us_page.dart';
import 'faq_page.dart';
import 'package:frontend/widgets/settings/settings_group.dart';
import 'package:frontend/widgets/settings/settings_section_title.dart';
import 'package:frontend/widgets/common/logout_button.dart';
import 'package:frontend/services/api_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String username = '';
  String email = '';
  String? profileImage;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> _refreshPage() async {
    await fetchUser();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> fetchUser() async {
    try {
      final response = await ApiService.getUser();
      final user = response['data'];
      if (!mounted) return;
      setState(() {
        username = user['username'] ?? '';
        email = user['email'] ?? '';
        profileImage = user['profile_image_url'];
      });
    } catch (e) {
      debugPrint("Error fetch user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;
    final horizontalPadding = isDesktop
        ? screenWidth * 0.18
        : isTablet
        ? screenWidth * 0.1
        : 24.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshPage,
            color: const Color(0xFF3B82F6),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: isDesktop
                        ? 300
                        : isTablet
                        ? 270
                        : 240,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 140,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF0E4399), Color(0xFF3B82F6)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 140,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF3B82F6), Color(0xFFF5F7F8)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 68,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Text(
                              'User Main Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 108,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: _buildProfileCard(
                              isTablet,
                              isDesktop,
                              username,
                              email,
                              profileImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 4,
                      bottom: 100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SettingsSectionTitle(title: 'ACCOUNT SETTINGS'),
                        const SizedBox(height: 12),
                        SettingsGroup(
                          items: [
                            SettingsGroupItem(
                              icon: Icons.person_outline_rounded,
                              label: 'Edit Profile',
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfilePage(),
                                  ),
                                );
                                if (result == true) {
                                  await fetchUser();
                                }
                              },
                            ),
                            SettingsGroupItem(
                              icon: Icons.tune_rounded,
                              label: 'Preferences',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PreferencesPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const SettingsSectionTitle(title: 'SUPPORT & LEGAL'),
                        const SizedBox(height: 12),
                        SettingsGroup(
                          items: [
                            SettingsGroupItem(
                              icon: Icons.help_outline_rounded,
                              label: 'Help Center',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const HelpCentrePage(),
                                  ),
                                );
                              },
                            ),
                            SettingsGroupItem(
                              icon: Icons.mail_outline_rounded,
                              label: 'Contact Us',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ContactUsPage(),
                                  ),
                                );
                              },
                            ),
                            SettingsGroupItem(
                              icon: Icons.help_outline_rounded,
                              label: 'FAQ',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FaqPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const LogoutButton(),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Version 1.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildProfileCard(
    bool isTablet,
    bool isDesktop,
    String username,
    String email,
    String? profileImage,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: isTablet ? 80 : 64,
                height: isTablet ? 80 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withAlpha(51),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profileImage != null && profileImage!.isNotEmpty
                      ? Image.network(
                          profileImage!,
                          width: isTablet ? 80 : 64,
                          height: isTablet ? 80 : 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/profile-photo.png',
                          width: isTablet ? 80 : 64,
                          height: isTablet ? 80 : 64,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFF59E0B), width: 1),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 18,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shinnosuke Nohara',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'shin@gmail.com',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEACD80).withAlpha(128),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFF8F5C06)],
                      stops: [0.0, 0.61],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'GOLD MEMBER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
