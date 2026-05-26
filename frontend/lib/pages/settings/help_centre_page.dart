import 'package:flutter/material.dart';

class HelpCentrePage extends StatelessWidget {
  const HelpCentrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 92,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7F8),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Help Center',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Color(0xFF94A3B8),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Search for topic...',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'HOW CAN WE HELP?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildHelpCard(
                              icon: Icons.event_busy_outlined,
                              iconColor: Color(0xFF3B82F6),
                              bgColor: Color(0x293B82F6),
                              title: 'Booking &\nCancellations',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildHelpCard(
                              icon: Icons.payments_outlined,
                              iconColor: Color(0xFF10B981),
                              bgColor: Color(0x2910B981),
                              title: 'Payment & Refunds',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildHelpCard(
                              icon: Icons.person_outline_rounded,
                              iconColor: Color(0xFF9747FF),
                              bgColor: Color(0x299747FF),
                              title: 'Profile & Account',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildHelpCard(
                              icon: Icons.shield_outlined,
                              iconColor: Color(0xFFEF4444),
                              bgColor: Color(0x29EF4444),
                              title: 'Safety & Security',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 34),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'FEATURED ARTICLES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildArticleCard(
                        tag: 'BOOKING',
                        tagColor: Color(0xFF3B82F6),
                        tagBg: Color(0x293B82F6),
                        title: 'Can I change my check-in date?',
                        description: 'Learn how to modify your reservation dates and check for availability...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildArticleCard(
                        tag: 'PREMIUM',
                        tagColor: Color(0xFFFBBF24),
                        tagBg: Color(0x29FBBF24),
                        title: 'Gold Member lounge access guide',
                        description: 'A complete list of participating airports and hotels offering exclusive lounges...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildArticleCard(
                        tag: 'PAYMENTS',
                        tagColor: Color(0xFF10B981),
                        tagBg: Color(0x2910B981),
                        title: 'When will I receive my refund?',
                        description: 'Refund processing times vary by payment method. Check out standard timeline...',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0x143B82F6),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0x2E3B82F6),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Still need help?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Our support team is available 24/7 to\nassist you with any questions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.call_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Contact Support',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHelpCard({required IconData icon, required Color iconColor, required Color bgColor, required String title}) {
    return Container(
      height: 134,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 59,
            height: 59,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildArticleCard({required String tag, required Color tagColor, required Color tagBg, required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: tagColor,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.7,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}