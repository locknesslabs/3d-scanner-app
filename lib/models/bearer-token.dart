import 'dart:convert';

class BearerToken {
  final String type;
  final String name;
  final dynamic abilities;
  final DateTime lastUsedAt;
  final DateTime expiresAt;
  String token = "";

  BearerToken({
    required this.type,
    required this.name,
    required this.token,
    required this.abilities,
    required this.lastUsedAt,
    required this.expiresAt,
  });

  static BearerToken fromJSON(Map<String, dynamic> json) {
    DateTime expiresAt = DateTime.parse(json["expiresAt"]);
    DateTime lastUsedAt = json["lastUsedAt"]!=null ? DateTime.parse(json["lastUsedAt"]): DateTime.now();

    return BearerToken(
      type: json["type"] ?? "",
      name: json["name"] ?? "",
      token: json["token"] ?? "",
      abilities: json["abilities"],
      lastUsedAt: lastUsedAt,
      expiresAt: expiresAt,
    );
  }

  static BearerToken empty() {
    return BearerToken(
      type: "",
      name: "",
      token: "",
      abilities: [],
      lastUsedAt: DateTime.now(),
      expiresAt: DateTime.now(),
    );
  }

  String get accessToken {
    if (token.isEmpty) return "";

    return '''Bearer ${token}''';
  }

  Map<String, dynamic> get toJSON {
    return {
      "type": type,
      "name": name,
      "token": token,
      "abilities": abilities,
      "lastUsedAt": lastUsedAt.toString(),
      "expiresAt": expiresAt.toString(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJSON);
  }
}
