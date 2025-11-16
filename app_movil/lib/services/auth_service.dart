class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _sessionCookie;

  String? get sessionCookie => _sessionCookie;

  void setSessionCookie(String? cookie) {
    _sessionCookie = cookie;
  }

  void clearSessionCookie() {
    _sessionCookie = null;
  }
}
