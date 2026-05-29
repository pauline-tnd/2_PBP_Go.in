import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'package:frontend/services/api_services.dart';

class AccountInformationPage extends StatefulWidget {
  const AccountInformationPage({super.key});

  @override
  State<AccountInformationPage> createState() => _AccountInformationPageState();
}

class _AccountInformationPageState extends State<AccountInformationPage> {
  String username = '';
  String email = '';
  int userId = 0;
  String createdAt = '';

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await ApiService.getUser();
      final user = response['data'];

      if (!mounted) return;

      final createdDate = DateTime.parse(user['created_at']);

      setState(() {
        username = user['username'] ?? '';
        email = user['email'] ?? '';
        userId = user['id'] ?? 0;
        createdAt =
            "${_monthName(createdDate.month)}, ${createdDate.day.toString().padLeft(2, '0')}, ${createdDate.year}";
      });
    } catch (e) {
      debugPrint("Error fetch user: $e");
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
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
          'Account Information',
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
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 25,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 98,
                        height: 98,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/profile-photo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 23,
                              height: 23,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEACD80).withAlpha(128),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'GOLD MEMBER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    iconBg: const Color(0x6194A3B8),
                    iconColor: const Color(0xFF64748B),
                    title: 'User ID',
                    value: userId.toString(),
                    isTop: true,
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.workspace_premium_rounded,
                    iconBg: const Color(0x40FBBF24),
                    iconColor: const Color(0xFFCFA34A),
                    title: 'Account Type',
                    customValue: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x40FBBF24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GOLD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.calendar_month_outlined,
                    iconBg: const Color(0x6194A3B8),
                    iconColor: const Color(0xFF64748B),
                    title: 'Date Joined',
                    value: createdAt,
                  ),
                  _divider(),
                  _buildInfoTile(
                    icon: Icons.check_circle_outline_rounded,
                    iconBg: const Color(0x2E10B981),
                    iconColor: const Color(0xFF10B981),
                    title: 'Account Status',
                    customValue: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    isBottom: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const EditProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  elevation: 0,
                  shadowColor: Colors.black.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SECURITY VERIFIED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 1,
        color: const Color(0x333B82F6),
      ),
    );
  }

  static Widget _buildInfoTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? value,
    Widget? customValue,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ),
          customValue ??
            Text(
              value ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
        ],
      ),
    );
  }
}