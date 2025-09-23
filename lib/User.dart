import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_page.dart';
import 'chatpage_updated.dart'; // Updated import for the new chat page
import 'package:flutter_application_1/globals.dart' as globals; // Use globals instead
import 'package:url_launcher/url_launcher.dart';
import 'user_reservations.dart'; // Import the new user reservations page
import 'main.dart'; // Import main.dart for ResortHomePage
import 'uploads_page.dart'; // Import uploads page for navigation
import 'payment_webview.dart';
import '../config/api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// User dashboard widget.
///

/// - Messaging with admin
/// - Viewing and editing profile
/// - Uploading 360-degree views
/// - Making and viewing reservations
class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    final int currentUserId = globals.loggedInUserId ?? 0; // Get from globals instead of SessionManager

    // DEBUG: Print the current user ID
    print("DEBUG: Current user ID from globals: $currentUserId");

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Mendez.jpg', height: 40, width: 40),
            const SizedBox(width: 10),
            const Text('User Dashboard', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const User()),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () {
              globals.clearLoginData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ResortHomePage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      // Drawer removed as per request

      // --- Main Body ---
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Mendez.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // increased opacity for better visibility
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visible menu items (replacing drawer) as horizontal row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextButton.icon(
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            // No navigation, just close menu equivalent
                          },
                        ),
                      ),
                      SizedBox(width: 24),
                      TextButton.icon(
                        icon: const Icon(Icons.bookmark),
                        label: const Text('My Reservations', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserReservationsPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 24),
                      TextButton.icon(
                        icon: const Icon(Icons.message),
                        label: const Text('Messages', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPageUpdated(
                                loggedInUserId: currentUserId,
                                otherUserId: 1,
                                otherUserName: 'Admin',
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 24),
                      TextButton.icon(
                        icon: const Icon(Icons.person),
                        label: const Text('Profile', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userId: currentUserId ?? 0,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 24),
                      TextButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('360 Viewing', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UploadsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Logout button moved to upper right in app bar actions
                const Divider(),
                // Existing content below
                Text(
                  'Current User ID: $currentUserId',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Make a Reservation', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReservationForm(userId: currentUserId ?? 0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reservation form widget for creating new reservations.
///
/// Allows users to select package type, day type, date, and number of guests.
/// Integrates with PayMongo for payment processing.
class ReservationForm extends StatefulWidget {
  final int userId;

  const ReservationForm({super.key, required this.userId});

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  List<dynamic> packageTypes = [];
  final List<String> dayTypes = ['Day Tour', 'Overnight', 'Whole Day'];

  int? selectedPackageId; // store as int
  String? selectedDayType;
  String? selectedWeekType; // auto-detected by date picker

  final TextEditingController guestsController = TextEditingController();
  DateTime? selectedDate;

  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPackageTypes();
  }

  @override
  void dispose() {
    guestsController.dispose();
    super.dispose();
  }

  Future<void> fetchPackageTypes() async {
    try {
      final url = Uri.parse(
          'http://192.168.100.238/flutter_api/reservation_get_packages.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['packages'] != null) {
          setState(() {
            packageTypes = data['packages']; // use "packages" array
            isLoading = false;
          });
        } else {
          print('No packages found or success=false');
          setState(() => isLoading = false);
        }
      } else {
        print('Failed to load packages: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching packages: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        // disable today
        return !date.isAtSameMomentAs(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ));
      },
    );

    if (picked != null && picked != selectedDate) {
      final isWeekend =
          picked.weekday == DateTime.saturday || picked.weekday == DateTime.sunday;
      final mappedWeekType = isWeekend ? 'Weekend' : 'Weekday';

      setState(() {
        selectedDate = picked;
        selectedWeekType = mappedWeekType;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected date: $mappedWeekType')),
      );
    }
  }
void submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  if (selectedPackageId == null || selectedDayType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select all dropdown fields')),
    );
    return;
  }

  if (selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a reservation date')),
    );
    return;
  }

  final guests = int.tryParse(guestsController.text);
  if (guests == null || guests <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid number of guests')),
    );
    return;
  }

  final data = {
    'user_id': widget.userId,
    'package_id': selectedPackageId,
    'day_type': selectedDayType,
    'week_type': selectedWeekType,
    'guests': guests,
    'reservation_date':
        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
  };

  print('DEBUG: Sending reservation: ${json.encode(data)}');

  try {
    // Step 1: Create Reservation
    final response = await http.post(
      Uri.parse(ApiConfig.createReservation),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final res = json.decode(response.body);

      if (res['success'] == true) {
        final reservationId = res['reservation_id'];
        final totalAmount = res['total_amount']; // make sure backend sends this

        // Step 2: Create Payment in PayMongo
        final paymentResponse = await http.post(
          Uri.parse(ApiConfig.createPayment),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'reservation_id': reservationId,
            'amount': totalAmount,
          }),
        );

        final payData = json.decode(paymentResponse.body);
        print('DEBUG: PayMongo create_payment response: $payData');

        if (payData['success'] == true && payData['checkout_url'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to PayMongo checkout...')),
          );

          // Step 3: Launch PayMongo checkout depending on platform
          if (kIsWeb) {
            // On web, open in same tab (or new tab if you change _self to _blank)
            await launchUrl(
              Uri.parse(payData['checkout_url']),
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_self', // '_self' same tab, '_blank' new tab
            );
          } else {
            // On mobile, show embedded WebView
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PaymentWebView(checkoutUrl: payData['checkout_url']),
              ),
            );
          }

          // Reset form
          setState(() {
            selectedPackageId = null;
            selectedDayType = null;
            selectedWeekType = null;
            guestsController.clear();
            selectedDate = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment error: ${payData['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res['error'] ?? 'Unknown error'}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('DEBUG: Exception: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/Mendez.jpg', height: 40, width: 40),
              const SizedBox(width: 10),
              const Text('Reservation Form'),
            ],
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Mendez.jpg', height: 40, width: 40),
            const SizedBox(width: 10),
            const Text('Reservation Form'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Making reservation for User ID: ${widget.userId}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Package Type Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Package Type'),
                value: selectedPackageId,
                items: packageTypes.map<DropdownMenuItem<int>>((item) {
                  return DropdownMenuItem(
                    value: int.parse(item['id'].toString()), // force int
                    child: Text(item['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedPackageId = val),
                validator: (value) =>
                    value == null ? 'Please select a package type' : null,
              ),
              const SizedBox(height: 16),

              // Day Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Day Type'),
                value: selectedDayType,
                items: dayTypes.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedDayType = val),
                validator: (value) =>
                    value == null ? 'Please select a day type' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              const Text('Reservation Date', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select reservation date',
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Tap to select date'
                        : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Guests Input
              TextFormField(
                controller: guestsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final guests = int.tryParse(value ?? '');
                  if (guests == null || guests <= 0) {
                    return 'Please enter a valid number of guests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Submit Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
