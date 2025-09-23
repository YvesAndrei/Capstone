class ApiConfig {
  // 🔹 Point to your Hostinger domain
  static const String baseUrl = "https://mendezresortandeventsplace.site/api/";

  // (Optional) WebSocket URL — update if you plan to run a WebSocket server
  static const String websocketUrl = "ws://mendezresortandeventsplace.site:8080";

  // -------------------------
  // Authentication & Users
  // -------------------------
  static const String login = "${baseUrl}login.php";
  static const String register = "${baseUrl}register.php";
  static const String getUsers = "${baseUrl}get_users.php";
  static const String getUserProfile = "${baseUrl}get_user_profile.php";
  static const String updateUserProfile = "${baseUrl}update_user_profile.php";
  static const String uploadProfilePicture = "${baseUrl}upload_profile_picture.php";
  static const String deleteUser = "${baseUrl}delete_user.php";
  static const String editUser = "${baseUrl}edit_user.php";
  static const String createUser = "${baseUrl}create_user.php";

  // -------------------------
  // Reservations
  // -------------------------
  static const String addReservation = "${baseUrl}add_reservation.php";
  static const String createReservation = "${baseUrl}create_reservation.php";
  static const String insertCustomerReservation = "${baseUrl}insert_customer_reservation.php";
  static const String getReservations = "${baseUrl}get_reservations.php";
  static const String getUserReservations = "${baseUrl}get_user_reservations.php";
  static const String approveReservation = "${baseUrl}approve_reservation.php";
  static const String rejectReservation = "${baseUrl}reject_reservation.php";
  static const String updateReservationStatus = "${baseUrl}update_reservations_status.php";
  static const String reservationGetPackages = "${baseUrl}reservation_get_packages.php";

  // -------------------------
  // Payments
  // -------------------------
  static const String createPayment = "${baseUrl}create_payment.php";
  static const String mockPayment = "${baseUrl}mock_payment.php";
  static const String paymongoWebhook = "${baseUrl}paymongo_webhook.php";
  static const String refundPaymentUrl = "${baseUrl}refund_payment.php";
  static const String requestRefund = "${baseUrl}request_refund.php";
  static const String adminRefund = "${baseUrl}admin_refund.php";
  static const String hasRefundRequest = "${baseUrl}has_refund_request.php";

  // -------------------------
  // Packages & Amenities
  // -------------------------
  static const String addPackage = "${baseUrl}add_package.php";
  static const String editPackage = "${baseUrl}edit_package.php";
  static const String deletePackage = "${baseUrl}delete_package.php";
  static const String getPackages = "${baseUrl}get_packages.php";
  static const String getReservationPackageTypes = "${baseUrl}get_reservation_package_types.php";

  static const String addAmenities = "${baseUrl}add_amenities.php";
  static const String editAmenities = "${baseUrl}edit_amenities.php";
  static const String deleteAmenities = "${baseUrl}delete_amenities.php";
  static const String getAmenities = "${baseUrl}get_amenities.php";

  // -------------------------
  // Messaging
  // -------------------------
  static const String checkMessages = "${baseUrl}check_messages.php";
  static const String getMessage = "${baseUrl}get_message.php";
  static const String getUsersWithMessages = "${baseUrl}get_users_with_messages.php";
  static const String sendMessage = "${baseUrl}send_message.php";
  static const String setTyping = "${baseUrl}set_typing.php";
  static const String testSendMessage = "${baseUrl}test_send_message.php";

  // -------------------------
  // Promos & Events
  // -------------------------
  static const String getPromos = "${baseUrl}get_promos.php";
  static const String getEvents = "${baseUrl}get_events.php";

  // -------------------------
  // Utilities
  // -------------------------
  static const String create = "${baseUrl}create.php";
  static const String db = "${baseUrl}db.php";
  static const String delete = "${baseUrl}delete.php";
  static const String read = "${baseUrl}read.php";
  static const String test = "${baseUrl}test.php";
  static const String update = "${baseUrl}update.php";
  static const String calendarReservations = "${baseUrl}get_reservations_calendar.php";
}
