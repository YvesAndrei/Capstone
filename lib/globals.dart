// globals.dart
library globals;

// User session data
int? loggedInUserId;
String? loggedInUserEmail;
int? loggedInUserRoleId;

// Helper function to check if user is logged in
bool isUserLoggedIn() {
  return loggedInUserId != null && loggedInUserId! > 0;
}

// Helper function to clear login data (for logout)
void clearLoginData() {
  loggedInUserId = null;
  loggedInUserEmail = null;
  loggedInUserRoleId = null;
}

// Helper function to print current login status (for debugging)
void printLoginStatus() {
  print("DEBUG - Login Status:");
  print("  User ID: $loggedInUserId");
  print("  Email: $loggedInUserEmail");
  print("  Role ID: $loggedInUserRoleId");
  print("  Is Logged In: ${isUserLoggedIn()}");
}