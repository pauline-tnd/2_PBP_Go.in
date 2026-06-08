class ReviewUser {
  final int id;
  final String username;
  final String? profileImage;

  ReviewUser({required this.id, required this.username, this.profileImage});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      profileImage: json['profile_image'],
    );
  }
}
