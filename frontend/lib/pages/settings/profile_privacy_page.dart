import 'package:flutter/material.dart';

class ProfilePrivacyPage extends StatefulWidget {
  const ProfilePrivacyPage({super.key});

  @override
  State<ProfilePrivacyPage> createState() => _ProfilePrivacyPageState();
}

class _ProfilePrivacyPageState extends State<ProfilePrivacyPage> {
  bool visibleToUsers = true;
  bool publicReviews = true;
  bool travelHistory = false;
  bool searchEngineIndexing = false;

  Widget buildSwitch(
    bool value,
    Function(bool) onChanged,
  ) {
    return Transform.scale(
      scale: 0.92,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF3B82F6),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFF3B82F6).withAlpha(64),
        trackOutlineColor:
            WidgetStateProperty.all(
              Colors.transparent,
            ),
      ),
    );
  }

  Widget privacyItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isTop = false,
    bool isBottom = false,
    bool showDivider = true,
    double height = 80,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 25 : 0),
          topRight: Radius.circular(isTop ? 25 : 0),
          bottomLeft: Radius.circular(isBottom ? 25 : 0),
          bottomRight: Radius.circular(isBottom ? 25 : 0),
        ),
        boxShadow: isTop || isBottom ? 
          [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ]
        : [],
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(41),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildSwitch(
                    value,
                    onChanged,
                  ),
                ],
              ),
            ),
          ),
          if (showDivider)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 22),
              height: 1,
              color: const Color(0xFF3B82F6).withAlpha(51),
            ),
        ],
      ),
    );
  }

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
          'Profile Privacy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
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
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRIVACY CONTROLS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            privacyItem(
              icon: Icons.visibility_outlined,
              title: 'Visible to other users',
              subtitle: 'Allow other travelers to find your profile and see your travel level.',
              value: visibleToUsers,
              onChanged: (value) {
                setState(() {
                  visibleToUsers = value;
                });
              },
              isTop: true,
            ),
            privacyItem(
              icon: Icons.mode_comment_outlined,
              title: 'Show my reviews publicly',
              subtitle: 'Your hotel reviews will be displayed with your name and profile picture.',
              value: publicReviews,
              onChanged: (value) {
                setState(() {
                  publicReviews = value;
                });
              },
            ),
            privacyItem(
              icon: Icons.share_outlined,
              title: 'Share my travel history',
              subtitle: 'Display a list of destinations you’ve visited on your public profile.',
              value: travelHistory,
              onChanged: (value) {
                setState(() {
                  travelHistory = value;
                });
              },
            ),
            privacyItem(
              icon: Icons.travel_explore_outlined,
              title: 'Allow search engine indexing',
              subtitle: 'Enabling this makes your profile searchable on Google and other search engines.',
              value: searchEngineIndexing,
              onChanged: (value) {
                setState(() {
                  searchEngineIndexing = value;
                });
              },
              isBottom: true,
              showDivider: false,
              height: 90,
            ),
            const SizedBox(height: 36),
            const Center(
              child: Text(
                'Your privacy settings are updated automatically.\nLast changed: Oct 24, 2025',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}