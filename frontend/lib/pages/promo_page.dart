import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PromoModel {
  final String image;
  final String code;

  const PromoModel({required this.image, required this.code});
}

final List<PromoModel> promos = [
  PromoModel(image: 'assets/images/promo/Promo1.jpeg', code: 'LUXURYSTAY50'),
  PromoModel(image: 'assets/images/promo/Promo2.jpeg', code: 'BOOKS30'),
  PromoModel(image: 'assets/images/promo/Promo3.jpeg', code: '15OYNE082026'),
];

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: Column(
        children: [
          SizedBox(
            height: 26.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 16.h,
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
                  top: 16.h,
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
                  top: 7.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Promo',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 5.w,
                  right: 5.w,
                  child: _goldMemberCard(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              children: [
                SizedBox(height: 2.h),
                ...promos.map(
                  (promo) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: PromoCard(promo: promo),
                  ),
                ),
                SizedBox(height: 2.h),
                Column(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 5.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'All coupons are verified and active',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldMemberCard() {
    return Container(
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withOpacity(.10),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFBBF24).withAlpha(64),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: .35.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'GOLD MEMBER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Exclusive Perks Active',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: .5.h),
                Text(
                  'You have 3 available coupons to use',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Container(
            width: 7.h,
            height: 7.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
              ),
            ),
            child: Icon(Icons.discount_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  final PromoModel promo;

  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 24.h,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                promo.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: List.generate(
                40,
                (index) => Expanded(
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: index.isEven
                        ? const Color(0xFF60A5FA)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: promo.code));
                    if (context.mounted) {
                      context.showAppSnackBar('Coupon copied!');
                      // ScaffoldMessenger.of(context)
                      //     .showSnackBar(
                      //   SnackBar(
                      //     content: Text(
                      //       'Coupon copied',
                      //       style: TextStyle(
                      //         fontSize: 13.sp,
                      //       ),
                      //     ),
                      //   ),
                      // );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4D8DFF)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          promo.code,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xFF4D8DFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.copy_rounded,
                          color: const Color(0xFF4D8DFF),
                          size: 5.w,
                        ),
                      ],
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
