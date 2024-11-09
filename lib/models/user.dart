class User {
  final String fullName;
  final String wallet;
  final double points;
  final String? email;
  final DateTime createdAt;

  User({
    required this.fullName,
    required this.email,
    required this.wallet,
    required this.points,
    required this.createdAt,
  });

  static User fromJSON(Map<String, dynamic> json) {
    DateTime _createdAt = json["createdAt"] !=null ? DateTime.parse(json["createdAt"]): DateTime.now();

    return new User(
      fullName: json["fullName"] ?? "",
      wallet: json["wallet"],
      points: double.parse(json["points"].toString()),
      email: json["email"] ?? "",
      createdAt: _createdAt,
    );
  }

  static User empty() {
    return User.fromJSON({
      "fullName": "",
      "wallet": "",
      "points": 0,
      "email": "",
      "createdAt": null,
    });
  }
}
