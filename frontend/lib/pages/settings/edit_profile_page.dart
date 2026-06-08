import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/extensions/snackbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? selectedImage;
  String? profileImageUrl;
  final ImagePicker picker = ImagePicker();
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final response = await ApiService.getUser();
      final user = response['data'];
      nameController.text = user['username'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone'] ?? '';
      setState(() {
        profileImageUrl = user['profile_image_url'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      context.showAppSnackBar(
        e.toString(),
        isError: true,
      );
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.updateUser(
        username: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
      );
      if (selectedImage != null) {
        await ApiService.updateProfileImage(
          selectedImage!,
        );
      }
      if (!mounted) return;
      context.showAppSnackBar(
        "Profile Updated Successfully!",
      );
      Navigator.pop(context, true);
    } catch (e) {
      context.showAppSnackBar(
        e.toString(),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() {
      selectedImage = File(image.path);
    });
  }

  void showImagePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
              child: const Text('Photo Library'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
              child: const Text('Take Photo'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7F8),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3B82F6),
          ),
        ),
      );
    }

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
          'Edit Profile',
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!) as ImageProvider
                      : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                        ? NetworkImage(profileImageUrl!) as ImageProvider
                        : const AssetImage("assets/images/profile-photo.png"),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: showImagePicker,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 28),
            sectionTitle("PERSONAL DATA"),
            const SizedBox(height: 12),
            buildCard(
              Column(
                children: [
                  buildTextField("Full Name", nameController),
                ],
              ),
            ),
            const SizedBox(height: 20),
            sectionTitle("CONTACT DETAILS"),
            const SizedBox(height: 12),
            buildCard(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField("Email Address", emailController),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Mobile Number",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text("+62"),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 365,
              child: ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save_as_outlined,
                        color: Colors.white,
                      ),
                label: Text(
                  isSaving ? "Saving..." : "Save Changes",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: isSaving ? null : saveProfile,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildCard(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 365),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}