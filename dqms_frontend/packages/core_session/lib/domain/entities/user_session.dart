import 'package:flutter/foundation.dart';

/// Core domain entity representing an authenticated user session.
@immutable
class UserSession {
  final String userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  const UserSession({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.metadata = const {},
  });

  /// Evaluates whether the access token is currently expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Converts entity to JSON Map for encrypted storage.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Deserializes entity from JSON Map.
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  UserSession copyWith({
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSession &&
        other.userId == userId &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(userId, accessToken, refreshToken, expiresAt);
  }
}
