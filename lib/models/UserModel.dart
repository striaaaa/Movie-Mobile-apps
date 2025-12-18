class User {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? oauthProvider;
  final String? oauthId;
  final String? refreshToken;
  final DateTime? refreshTokenExpiry;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.oauthProvider,
    this.oauthId,
    this.refreshToken,
    this.refreshTokenExpiry,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      oauthProvider: json['oauth_provider'],
      oauthId: json['oauth_id'],
      refreshToken: json['refresh_token'],
      refreshTokenExpiry: json['refresh_token_expiry'] != null
          ? DateTime.parse(json['refresh_token_expiry'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'oauth_provider': oauthProvider,
      'oauth_id': oauthId,
      'refresh_token': refreshToken,
      'refresh_token_expiry':
          refreshTokenExpiry?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
