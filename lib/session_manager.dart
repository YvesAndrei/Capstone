import 'globals.dart' as globals;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  int? userId;
  String? email;
  int? roleId;

  void saveUser({
    required int userId,
    required String email,
    required int roleId,
  }) {
    this.userId = userId;
    this.email = email;
    this.roleId = roleId;

    // Update globals with the same data
    globals.loggedInUserId = userId;
    globals.loggedInUserEmail = email;
    globals.loggedInUserRoleId = roleId;
    
    print("Session saved - User ID: $userId, Email: $email, Role ID: $roleId");
  }

  // Add method to sync from globals
  void syncFromGlobals() {
    if (globals.loggedInUserId != null) {
      userId = globals.loggedInUserId;
      email = globals.loggedInUserEmail;
      roleId = globals.loggedInUserRoleId;
      print("Session synced from globals - User ID: $userId");
    }
  }

  // Add method to clear both session manager and globals
  void clearSession() {
    userId = null;
    email = null;
    roleId = null;
    globals.clearLoginData();
    print("Session cleared");
  }
}
