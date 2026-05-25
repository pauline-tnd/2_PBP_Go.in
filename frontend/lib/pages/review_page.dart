import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HotelReviewDetail {
  final String hotelName;
  final String roomType;
  final String imageName;
  final DateTime checkOutDate;
  final List<String> facilities;

  HotelReviewDetail({
    required this.hotelName,
    required this.roomType,
    required this.imageName,
    required this.checkOutDate,
    required this.facilities,
  });

  factory HotelReviewDetail.fromJson(Map<String, dynamic> json) {
    var facilityList = json['hotel']['hotel_facilities'] as List? ?? [];
    List<String> parsedFacilities = facilityList
      .map((f) => f['name'].toString())
      .toList();

    var imageList = json['hotel']['hotel_images'] as List? ?? [];
    String img = '';
      if (imageList.isNotEmpty && imageList[0]['image'] != null) {
        img = imageList[0]['image'].toString();
      }
    return HotelReviewDetail(
      hotelName: json['hotel']['name'] ?? 'Unknown Hotel',
      roomType: json['room_type'] ?? 'Standard Room',
      imageName: img,
      checkOutDate: DateTime.parse(json['check_out']),
      facilities: parsedFacilities,
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
  @override
  void initState() {
    super.initState();
    _hotelDetailFuture = _fetchHotelDetail();
  }
  Future<HotelReviewDetail> _fetchHotelDetail() async {
    final String apiUrl = "http://localhost:8000/api/bookings/${widget.bookingId}/review-details";
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 5|qFTHyhTKnuwNY9ltGuzEvTnPqWdBTG8L3unjjJPg42b3e5dd' // kalau pakai auth
      });
      print("STATUS CODE: ${response.statusCode}");
      print("RAW RESPONSE: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return HotelReviewDetail.fromJson(data['data']);
      } else {
        throw Exception("Server gagal merespon dengan kode ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke server: $e");
    }
  }

  void submitReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih rating terlebih dahulu")),
      );
      return;
    }
    setState(() => isSubmitting = true);
    try {
      final payload = {
        'booking_id': widget.bookingId,
        'rating': selectedRating,
        'review_text': reviewController.text,
        'is_anonymous': isAnonymous,
        'tags': selectedHighlights.toList(), 
      };
      final response = await http.post(
        Uri.parse("http://localhost:8000/api/reviews"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review berhasil dikirim!")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Gagal menyimpan review ke database.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
                                  onTap: () {
                                    setState(() => selectedRating = starValue);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      starValue <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 38,
                                      color: starValue <= selectedRating 
                                          ? const Color(0xFFFFB800)
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
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "Maximum 500 characters",
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
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, color: Color(0xFF94A3B8), size: 28),
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
                          final isSelected = selectedHighlights.contains(facility);
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
                              color: isSelected ? Colors.white : const Color(0xFF3B82F6).withOpacity(0.88),
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF3B82F6).withOpacity(0.38),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7F8),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isAnonymous = !isAnonymous),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isAnonymous ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isAnonymous ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                              size: 20,
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
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
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