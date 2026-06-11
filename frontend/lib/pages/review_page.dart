import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:frontend/models/hotelReviewDetail.dart';
import 'package:frontend/extensions/snackbar.dart';
import 'package:frontend/services/api_services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/facility.dart';
import 'package:frontend/models/hotelReviewDetail.dart';

class ReviewPage extends StatefulWidget {
  final String bookingId;
  const ReviewPage({super.key, required this.bookingId});
  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  bool isAnonymous = false;
  bool isSubmitting = false;
  final Set<String> selectedHighlights = {};
  late Future<HotelReviewDetail> _hotelDetailFuture;
  HotelReviewDetail? hotelDetail;
  File? selectedImage;

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
      barrierColor: Colors.black.withAlpha(230),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(imageUrl, fit: BoxFit.contain),
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
                        color: Colors.black.withValues(alpha: 0.6),
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
    final String apiUrl =
        "http://localhost:8000/api/bookings/${widget.bookingId}/review-details";
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final bookingData = jsonDecode(response.body)['data'];
        final parsedData = HotelReviewDetail.fromJson(bookingData);
        setState(() {
          hotelDetail = parsedData;
        });

        return parsedData;
      }
      throw Exception("Failed ${response.statusCode}");
    } catch (e) {
      throw Exception("Connection failed: $e");
    }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              Icon(Icons.camera_alt_outlined, color: const Color(0xFF0F172A)),
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
      context.showAppSnackBar('Select the rating first', isWarning: true);
      return;
    }
    if (hotelDetail == null) return;
    if (hotelDetail?.userId == null ||
        hotelDetail?.roomId == null ||
        hotelDetail?.bookingDetailId == null) {
      context.showAppSnackBar('Review data incomplete', isWarning: true);
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

      context.showAppSnackBar('Review submitted successfully');

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;

      context.showAppSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
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
          'Write a Review',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: FutureBuilder<HotelReviewDetail>(
        future: _hotelDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text("${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }
          final hotel = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 74,
                                      height: 74,
                                      color: const Color(0xFFD9D9D9),
                                      child: const Icon(
                                        Icons.hotel_rounded,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
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
                            ),
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
                                  onTap: () {
                                    setState(() => selectedRating = starValue);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      starValue <= selectedRating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 38,
                                      color: starValue <= selectedRating
                                          ? const Color(0xFFFFB800)
                                          : const Color(
                                              0xFF94A3B8,
                                            ).withAlpha(192),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              selectedRating == 0
                                  ? "Select Rating"
                                  : "$selectedRating Stars Selected",
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
                        "Share your experience *",
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                hintText:
                                    "Tell us about the service, rooms, and location...",
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                counterText: "",
                              ),
                              onChanged: (text) => setState(() {}),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Maximum 500 characters",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF94A3B8,
                                  ).withAlpha(192),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Add photos (Optional)",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
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
                                          color: Colors.black.withAlpha(38),
                                          blurRadius: 6,
                                        ),
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
                      const SizedBox(height: 24),
                      const Text(
                        "What did you love most?",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: hotel.facilities.map((facility) {
                          final isSelected = selectedHighlights.contains(
                            facility,
                          );
                          return FilterChip(
                            label: Text(facility),
                            selected: isSelected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  selectedHighlights.add(facility);
                                } else {
                                  selectedHighlights.remove(facility);
                                }
                              });
                            },
                            labelStyle: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF3B82F6).withAlpha(224),
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF3B82F6).withAlpha(97),
                              ),
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
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
                                          actionsPadding:
                                              const EdgeInsets.fromLTRB(
                                                20,
                                                0,
                                                20,
                                                20,
                                              ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                );
                                              },
                                              child: const Text(
                                                "CANCEL",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF3B82F6,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 10,
                                                    ),
                                              ),
                                              child: const Text(
                                                "CONFIRM",
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Plus Jakarta Sans',
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
                              disabledBackgroundColor: const Color(
                                0xFF3B82F6,
                              ).withAlpha(153),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 3,
                              shadowColor: Colors.black.withAlpha(64),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "Keep my review anonymous. My profile picture and name will be censored from other travelers",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF3B82F6,
                            ).withAlpha(153),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withAlpha(64),
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
                              : const Text(
                                  "Submit Review",
                                  style: TextStyle(
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
