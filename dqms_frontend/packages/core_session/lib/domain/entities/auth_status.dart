/// System-wide authentication status states.
enum AuthStatus {
  /// Initial unknown state before storage check completes
  unknown,

  /// Active valid session present
  authenticated,

  /// No session active or explicitly logged out
  unauthenticated,

  /// Session token expired and refresh failed
  expired,
}
