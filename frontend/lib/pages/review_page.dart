import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:frontend/services/api_services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Facility {
  final String name;
  final String icon;

  Facility({
    required this.name,
    required this.icon,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      name: json['name'] ?? '',
      icon: json['icon']?['icon']?.toString().trim() ?? '',
    );
  }
}

class HotelReviewDetail {
  final String hotelName;
  final String roomType;
  final String imageName;
  final DateTime checkOutDate;
  final List<Facility> facilities;
  final int? roomId;
  final int? bookingDetailId;
  final int? userId;
  final int? reviewRating;
  final String? reviewDescription;
  final String? reviewImage;

  HotelReviewDetail({
    required this.hotelName,
    required this.roomType,
    required this.imageName,
    required this.checkOutDate,
    required this.facilities,
    required this.roomId,
    required this.bookingDetailId,
    required this.userId,
    this.reviewRating,
    this.reviewDescription,
    this.reviewImage,
  });

  factory HotelReviewDetail.fromJson(Map<String, dynamic> json) {
    var facilityList = json['hotel']['hotel_facilities'] as List? ?? [];
      List<Facility> parsedFacilities = facilityList
          .map((f) => Facility.fromJson(f))
          .toList();
    var imageList = json['hotel']['hotel_images'] as List? ?? [];
    String img = '';
      if (imageList.isNotEmpty && imageList[0]['image'] != null) {
        img = imageList[0]['image'].toString();
      }
    final review = json['review'];
    return HotelReviewDetail(
      hotelName: json['hotel']['name'] ?? 'Unknown Hotel',
      roomType: json['room_type'] ?? 'Standard Room',
      imageName: img,
      checkOutDate: DateTime.parse(json['check_out']),
      facilities: parsedFacilities,
      roomId: json['room_id'] is int
          ? json['room_id']
          : int.tryParse(json['room_id']?.toString() ?? ''),
      bookingDetailId: json['booking_detail_id'] is int
          ? json['booking_detail_id']
          : int.tryParse(json['booking_detail_id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      reviewRating: review?['rating'],
      reviewDescription: review?['description'],
      reviewImage: review?['image_url'],
    );
  }

  String get relativeTime {
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanCheckOut = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    final difference = cleanToday.difference(cleanCheckOut).inDays;
    if (difference <= 0) {
      return "STAYED TODAY";
    } else if (difference == 1) {
      return "STAYED 1 DAY AGO";
    } else {
      return "STAYED $difference DAYS AGO";
    }
  }
}

class ReviewPage extends StatefulWidget {
  final String bookingId;
  final bool isReadOnly;
  const ReviewPage({super.key, required this.bookingId, this.isReadOnly = false});
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool _isDisposed = false;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? reviewImageUrl;
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool isAnonymous = false;
  bool isSubmitting = false;
  final Set<String> selectedHighlights = {};
  late Future<HotelReviewDetail> _hotelDetailFuture;
  HotelReviewDetail? hotelDetail;
  @override
  void initState() {
    super.initState();
    _hotelDetailFuture = Future.microtask(() => _fetchHotelDetail());
  }
  @override
  void dispose() {
    _isDisposed = true;
    reviewController.dispose();
    super.dispose();
  }
  void safeSetState(VoidCallback fn) {
    if (mounted && !_isDisposed) {
      setState(fn);
    }
  }
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // tombol close
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<HotelReviewDetail> _fetchHotelDetail() async {
    try {
      final response = await ApiService.fetchReviewDetails(
        int.parse(widget.bookingId),
      );
      if (_isDisposed || !mounted) {
        throw Exception("Disposed");
      }
      final detail = HotelReviewDetail.fromJson(response['data']);
      if (!_isDisposed && mounted) {
        if (_isDisposed || !mounted) return detail;
        setState(() {
          hotelDetail = detail;

          if (widget.isReadOnly) {
            selectedRating = detail.reviewRating ?? 0;
            reviewController.text = detail.reviewDescription ?? '';
            reviewImageUrl = detail.reviewImage;
          }
        });
      }
      return detail;
    } catch (e) {
      if (_isDisposed) rethrow;
      rethrow;
    }
  }
  Widget _buildPickerOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              icon,
              size: 28,
              color: const Color(0xFF0F172A),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          details.globalPosition.dx,
          details.globalPosition.dy,
          0,
          0,
        ),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white,
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.photo_library_outlined,
                color: const Color(0xFF0F172A),
              ),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Camera',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.camera_alt_outlined,
                color: const Color(0xFF0F172A),
              ),
            ],
          ),
        ),
      ],
    );

    if (selected == 'gallery') {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        safeSetState(() {
          selectedImage = File(image.path);
        });
      }
    }

    if (selected == 'camera') {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        safeSetState(() {
          selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> submitReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih rating terlebih dahulu"),
        ),
      );
      return;
    }
    if (hotelDetail == null) return;
    if (hotelDetail?.userId == null ||
        hotelDetail?.roomId == null ||
        hotelDetail?.bookingDetailId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data review tidak lengkap"),
        ),
      );
      return;
    }
    if (!mounted) return;
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    try {
      await ApiService.storeReview(
        userId: hotelDetail!.userId!,
        roomId: hotelDetail!.roomId!,
        bookingDetailId: hotelDetail!.bookingDetailId!,
        rating: selectedRating,
        description: reviewController.text,
        createdAt: DateTime.now().toIso8601String(),
        image: selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review berhasil dikirim!"),
        ),
      );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
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
        title: Text(
          widget.isReadOnly
            ? 'Your Review'
            : 'Write a Review',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
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
      body: FutureBuilder<HotelReviewDetail>(
        future: _hotelDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text("${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }
          if (!mounted || snapshot.data == null) {
            return const SizedBox();
          }
          final hotel = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                hotel.imageName,
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 74,
                                  height: 74,
                                  color: const Color(0xFFD9D9D9),
                                  child: const Icon(Icons.hotel_rounded, color: Colors.grey),
                                ),
                              )
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.relativeTime,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hotel.hotelName,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hotel.roomType,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              "How was your stay?",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: Color(0xFF000000),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                int starValue = index + 1;
                                return GestureDetector(
                                  onTap: widget.isReadOnly
                                    ? null
                                    : () {
                                        setState(() => selectedRating = starValue);
                                      },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      starValue <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 38,
                                      color: starValue <= selectedRating 
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF94A3B8).withOpacity(0.75),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedRating == 0 ? "Select Rating" : "$selectedRating Stars Selected",
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Your Experience *",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            TextField(
                              controller: reviewController,
                              maxLines: 5,
                              maxLength: 500,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Tell us about the service, rooms, and location...",
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                              onChanged: (text) => setState(() {}),
                              enabled: !widget.isReadOnly,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "${500 - reviewController.text.length} characters left",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8).withOpacity(0.75),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Photos (Optional)",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTapDown: (selectedImage == null && !widget.isReadOnly)
                            ? _showImagePickerOptions
                            : null,
                        child: Stack(
                          children: [
                            DottedBorder(
                              color: const Color(0xFFCBD5E1),
                              strokeWidth: 2,
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(16),
                              dashPattern: const [8, 8],
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: (selectedImage != null || reviewImageUrl != null)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: widget.isReadOnly
                                        ? GestureDetector(
                                            onTap: () {
                                              if (reviewImageUrl != null && reviewImageUrl!.isNotEmpty) {
                                                _showImagePreview(reviewImageUrl!);
                                              }
                                            },
                                            child: Image.network(
                                              reviewImageUrl ?? '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          )
                                        : Image.file(
                                            selectedImage!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                    )
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt_outlined,
                                            color: Color(0xFF94A3B8),
                                            size: 28,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "CAMERA/\nGALLERY",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Rubik',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          )
                                        ],
                                      ),
                              ),
                            ),

                            // ICON EDIT
                            if (selectedImage != null && !widget.isReadOnly)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTapDown: _showImagePickerOptions,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      size: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7F8),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      if (!widget.isReadOnly)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                          onPressed: (isSubmitting || widget.isReadOnly)
                            ? null
                            : () async {
                                if (!mounted) return;
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      title: const Text(
                                        "Confirm Submit Review",
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      content: const Text(
                                        "Are you sure you want to submit this review?",
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext, false);
                                          },
                                          child: const Text(
                                            "CANCEL",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Plus Jakarta Sans',
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext, true);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF3B82F6),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            "CONFIRM",
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true && mounted) {
                                  submitReview();
                                }
                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF3B82F6).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.25),
                          ),
                          child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                widget.isReadOnly
                                  ? "Your Review"
                                  : "Submit Review",
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}