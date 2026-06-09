import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool promosOffers = true;
  bool bookingUpdates = true;
  bool reminders = true;
  bool newsletter = true;
  bool monthlyStats = true;

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

  Widget notificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isTop = false,
    bool isBottom = false,
    bool showDivider = true,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 25 : 0),
          topRight: Radius.circular(isTop ? 25 : 0),
          bottomLeft: Radius.circular(isBottom ? 25 : 0),
          bottomRight: Radius.circular(isBottom ? 25 : 0),
        ),
        boxShadow: isTop || isBottom
        ? [
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
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              child: Row(
                children: [
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
              margin: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              height: 1,
              color:
                  const Color(0xFF3B82F6).withAlpha(51),
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
          'Notification Settings',
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
        padding: const EdgeInsets.fromLTRB(
          24,
          20,
          24,
          40,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'PUSH NOTIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            notificationItem(
              title: 'Promos & Offers',
              subtitle: 'Exclusive deals and flash sales',
              value: promosOffers,
              onChanged: (value) {
                setState(() {
                  promosOffers = value;
                });
              },
              isTop: true,
            ),
            notificationItem(
              title: 'Booking Updates',
              subtitle: 'Confirmation and itinerary changes',
              value: bookingUpdates,
              onChanged: (value) {
                setState(() {
                  bookingUpdates = value;
                });
              },
            ),
            notificationItem(
              title: 'Reminders',
              subtitle: 'Check-in times and stay alerts',
              value: reminders,
              onChanged: (value) {
                setState(() {
                  reminders = value;
                });
              },
              isBottom: true,
              showDivider: false,
            ),
            const SizedBox(height: 30),
            const Text(
              'EMAIL NOTIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            notificationItem(
              title: 'Newsletter',
              subtitle: 'Weekly travel tips and inspiration',
              value: newsletter,
              onChanged: (value) {
                setState(() {
                  newsletter = value;
                });
              },
              isTop: true,
            ),
            notificationItem(
              title: 'Monthly Stats',
              subtitle: 'Your travel history and summary',
              value: monthlyStats,
              onChanged: (value) {
                setState(() {
                  monthlyStats = value;
                });
              },
              isBottom: true,
              showDivider: false,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Notification preferences are saved automatically.\nLast updated: Oct 24, 2025',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
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