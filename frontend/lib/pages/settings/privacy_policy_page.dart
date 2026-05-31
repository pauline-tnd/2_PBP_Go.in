import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.5,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.65,
          fontWeight: FontWeight.w400,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget subTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.65,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
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
          'Privacy Policy',
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
        padding: const EdgeInsets.fromLTRB(29, 20, 29, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated : February 01, 2026',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome to ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  TextSpan(
                    text: 'Go.in',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            bodyText('This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application for hotel booking services.'),
            bodyText('By using the App, you agree to the collection and use of information in accordance with this Privacy Policy.'),
            const SizedBox(height: 8),
            sectionTitle('1. Information We Collect'),
            bodyText('We may collect the following types of information:'),
            subTitle('1.1 Personal Information'),
            bulletItem('Full name'),
            bulletItem('Email address'),
            bulletItem('Phone number'),
            bulletItem('Billing address'),
            bulletItem('Payment details processed through secure third-party providers'),
            bulletItem('Identification information if required by hotel or local law'),
            subTitle('1.2 Booking Information'),
            bulletItem('Hotel preferences'),
            bulletItem('Check-in and check-out dates'),
            bulletItem('Special requests'),
            bulletItem('Booking history'),
            subTitle('1.3 Device & Usage Information'),
            bulletItem('Device type and model'),
            bulletItem('Operating system'),
            bulletItem('IP address'),
            bulletItem('App version'),
            bulletItem('Log data and usage behavior'),
            subTitle('1.4 Location Information'),
            bodyText('With your consent, we may collect approximate or precise location data to improve your experience.'),
            bulletItem('Show nearby hotels'),
            bulletItem('Improve search results'),
            bulletItem('Provide personalized recommendations'),
            const SizedBox(height: 10),
            sectionTitle('2. How We Use Your Information'),
            bodyText('We use the collected information to:'),
            bulletItem('Process and manage hotel bookings'),
            bulletItem('Facilitate payments'),
            bulletItem('Provide customer support'),
            bulletItem('Send booking confirmations and updates'),
            bulletItem('Improve app functionality and user experience'),
            bulletItem('Send promotional offers if enabled by the user'),
            bulletItem('Comply with legal obligations'),
            const SizedBox(height: 10),
            sectionTitle('3. Data Security'),
            bodyText('We implement reasonable administrative, technical, and physical safeguards to protect your personal information. However, no electronic transmission or storage method is completely secure.'),
            const SizedBox(height: 10),
            sectionTitle('4. Third-Party Services'),
            bodyText('Our application may use third-party services such as payment gateways, analytics providers, and hotel partners. These services may collect information in accordance with their own privacy policies.'),
            const SizedBox(height: 10),
            sectionTitle('5. Your Rights'),
            bulletItem('Access and update your personal information'),
            bulletItem('Request account deletion'),
            bulletItem('Disable marketing communications'),
            bulletItem('Manage notification preferences'),
            const SizedBox(height: 10),
            sectionTitle('6. Contact Us'),
            bodyText('If you have questions regarding this Privacy Policy, please contact our support team through the application.'),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                '© 2026 Go.in — All Rights Reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
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