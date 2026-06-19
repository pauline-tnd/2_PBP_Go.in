import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/bookingDetail.dart';
import 'package:frontend/pages/activity/booking_detail_page.dart';
import 'package:frontend/services/api_services.dart';
import 'package:frontend/widgets/adaptive_image.dart';
import 'package:local_auth/local_auth.dart';

class PaymentConfirmationPage extends StatefulWidget {
  const PaymentConfirmationPage({
    super.key,
    required this.hotelName,
    required this.hotelLocation,
    required this.bookingDetails,
    required this.bookingId,
    this.previewImageUrl = '',
    this.checkIn,
    this.checkOut,
  });

  final String hotelName;
  final String hotelLocation;
  final List<BookingDetail> bookingDetails;
  final int bookingId;
  final String previewImageUrl;
  final DateTime? checkIn;
  final DateTime? checkOut;

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  static const _bg = Color(0xFFF3F4F6);
  static const _card = Colors.white;
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF9CA3AF);
  static const _line = Color(0xFFE5E7EB);
  static const _primary = Color(0xFF3B82F6);

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isSubmitting = false;
  bool _isPromptOpen = false;

  DateTime get _checkIn =>
      widget.checkIn ?? DateTime.now().add(const Duration(days: 1));

  DateTime get _checkOut =>
      widget.checkOut ?? _checkIn.add(const Duration(days: 1));

  int get _totalNights => _checkOut.difference(_checkIn).inDays;

  double get _roomRateTotal => widget.bookingDetails.fold<double>(
    0,
    (sum, detail) => sum + (detail.room.price * detail.quantity * _totalNights),
  );

  double get _addOnTotal => widget.bookingDetails.fold<double>(
    0,
    (sum, detail) =>
        sum +
        detail.selectedAddOns.fold<double>(
          0,
          (addOnSum, addOn) =>
              addOnSum + (addOn.price * detail.quantity * _totalNights),
        ),
  );

  double get _total => _roomRateTotal + _addOnTotal;

  Future<void> _processPayment() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ApiService.updateBooking(widget.bookingId, 'paid');
      final resp = await ApiService.fetchBookingById(widget.bookingId);
      final payload = resp['data'] as Map<String, dynamic>? ?? resp;
      final booking = Booking.fromJson(payload);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BookingDetailPage(booking: booking)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to confirm payment: $error'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleBack() async {
    Navigator.pop(context);
    try {
      await ApiService.updateBooking(widget.bookingId, 'cancelled');
    } catch (_) {}
  }

  Future<void> _confirmPayment() async {
    if (_isSubmitting || _isPromptOpen) return;

    setState(() {
      _isPromptOpen = true;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _FingerprintPromptDialog(
        onAuthenticate: () => _handleBiometricAuthentication(dialogContext),
        onCancel: () => Navigator.of(dialogContext).pop(),
      ),
    );

    if (mounted) {
      setState(() {
        _isPromptOpen = false;
      });
    }
  }

  Future<void> _handleBiometricAuthentication(
    BuildContext dialogContext,
  ) async {
    Future<void> cancelAndPop({String? errorMsg}) async {
      try {
        Navigator.of(dialogContext).pop();
      } catch (_) {}
      try {
        await ApiService.updateBooking(widget.bookingId, 'cancelled');
      } catch (_) {}
      if (!mounted) return;
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      Navigator.pop(context);
    }

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!isSupported || !canCheckBiometrics) {
        throw Exception(
          'Fingerprint authentication is not available on this device.',
        );
      }
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final hasFingerprint =
          availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak);
      if (!hasFingerprint) {
        throw Exception('No fingerprint biometric is enrolled on this device.');
      }
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to confirm this payment',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (!mounted) return;
      if (isAuthenticated) {
        try {
          Navigator.of(dialogContext).pop();
        } catch (_) {}
        await _processPayment();
      } else {
        await cancelAndPop();
      }
    } on PlatformException catch (error) {
      await cancelAndPop(
        errorMsg:
            error.message ??
            'Fingerprint authentication could not be completed.',
      );
    } catch (error) {
      await cancelAndPop(errorMsg: '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewImage = widget.previewImageUrl.isNotEmpty
        ? widget.previewImageUrl
        : (widget.bookingDetails.isNotEmpty
              ? widget.bookingDetails.first.roomImage
              : '');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              _PaymentAppBar(onBack: _handleBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: Column(
                    children: [
                      _OverviewCard(
                        hotelName: widget.hotelName,
                        hotelLocation: widget.hotelLocation,
                        imageUrl: previewImage,
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Booking Details',
                        icon: Icons.calendar_month_rounded,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Check-in', _formatDate(_checkIn)),
                            const SizedBox(height: 12),
                            _infoRow('Check-out', _formatDate(_checkOut)),
                            const SizedBox(height: 14),
                            ..._buildBookingLines(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Price Summary',
                        icon: Icons.account_balance_wallet_outlined,
                        child: Column(
                          children: [
                            _priceRow('Room Rate', _roomRateTotal),
                            const SizedBox(height: 8),
                            _priceRow('Addons', _addOnTotal),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: _line),
                            ),
                            _priceRow('TOTAL', _total, isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Use Coupon',
                        icon: Icons.confirmation_num_outlined,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'LUXURYSTAY50',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _priceRow('Discount', 0),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: _line),
                            ),
                            _priceRow('TOTAL PAYMENT', _total, isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Payment Method',
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: const [
                              _VisaBadge(),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Visa - - - - 8888',
                                      style: TextStyle(
                                        color: _text,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Expires 12/26',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBookingLines() {
    final widgets = <Widget>[];

    for (final detail in widget.bookingDetails) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${detail.quantity}x ${detail.room.type}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail.selectedAddOns.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _detailValueRow(
                    'Add on',
                    detail.selectedAddOns.map((item) => item.name).join(', '),
                  ),
                ],
                if (detail.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _detailValueRow('Notes', detail.notes.trim()),
                ],
              ],
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return widgets;
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailValueRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _text,
              fontSize: isBold ? 13 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            color: _text,
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  static String _formatCurrency(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
      buffer.write(value[i]);
    }
    return 'Rp.${buffer.toString()},00';
  }
}

class _PaymentAppBar extends StatelessWidget {
  const _PaymentAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: _PaymentConfirmationPageState._bg,
        border: Border(
          bottom: BorderSide(color: _PaymentConfirmationPageState._line),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: _PaymentConfirmationPageState._text,
          ),
          const Expanded(
            child: Text(
              'Booking Overview',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _PaymentConfirmationPageState._text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PaymentConfirmationPageState._card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(
                  icon,
                  color: _PaymentConfirmationPageState._primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: _PaymentConfirmationPageState._text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              title,
              style: const TextStyle(
                color: _PaymentConfirmationPageState._text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.hotelName,
    required this.hotelLocation,
    required this.imageUrl,
  });

  final String hotelName;
  final String hotelLocation;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _PaymentConfirmationPageState._card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? AdaptiveImage(
                    imagePath: imageUrl,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _PaymentConfirmationPageState._text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: _PaymentConfirmationPageState._muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hotelLocation.isEmpty
                            ? 'Location unavailable'
                            : hotelLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _PaymentConfirmationPageState._muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 78,
      height: 78,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(
        Icons.hotel_rounded,
        color: _PaymentConfirmationPageState._muted,
      ),
    );
  }
}

class _VisaBadge extends StatelessWidget {
  const _VisaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'VISA',
        style: TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _FingerprintPromptDialog extends StatefulWidget {
  const _FingerprintPromptDialog({
    required this.onAuthenticate,
    required this.onCancel,
  });

  final Future<void> Function() onAuthenticate;
  final VoidCallback onCancel;

  @override
  State<_FingerprintPromptDialog> createState() =>
      _FingerprintPromptDialogState();
}

class _FingerprintPromptDialogState extends State<_FingerprintPromptDialog> {
  bool _started = false;
  bool _isChecking = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.onAuthenticate();
      if (!mounted) return;
      setState(() {
        _isChecking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Payment',
                style: TextStyle(
                  color: _PaymentConfirmationPageState._text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please scan your fingerprint\nto confirm your payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _PaymentConfirmationPageState._muted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: _PaymentConfirmationPageState._primary,
                  shape: BoxShape.circle,
                ),
                child: _isChecking
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fingerprint_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 6),
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.fingerprint_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
