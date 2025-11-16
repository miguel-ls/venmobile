class User {
  final int id;
  final String username;
  final String email;
  final int profileId;

  User({required this.id, required this.username, required this.email, required this.profileId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileId: json['profile_id'],
    );
  }
}
