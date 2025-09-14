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
import '../config/api.dart';


class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    final int currentUserId = globals.loggedInUserId ?? 0; // Get from globals instead of SessionManager

    // DEBUG: Print the current user ID
    print("DEBUG: Current user ID from globals: $currentUserId");

    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),

      // --- Drawer for navigation ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'User Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // --- Messaging Drawer Tile ---
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPageUpdated(
                      loggedInUserId: currentUserId,
                      otherUserId: 1, // Use int directly
                      otherUserName: 'Admin',
                    ),
                  ),
                );
              },
            ),
            // --- Profile Drawer Tile ---
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                print("DEBUG: Navigating to ProfilePage with userId: $currentUserId");
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      userId: currentUserId ?? 0, // from globals
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('360 Viewing'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
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
      ),

      // --- Main Body ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DEBUG: Show current user ID on screen
            Text(
              'Current User ID: $currentUserId',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Make a Reservation'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ReservationForm(userId: currentUserId ?? 0), // from globals
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: const Text('My Reservations'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserReservationsPage(), // Navigate to new user reservations page
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================== RESERVATION FORM ==================
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
          final checkoutUrl = Uri.parse(payData['checkout_url']);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to PayMongo checkout...')),
          );

          // Step 3: Launch PayMongo checkout
          if (await canLaunchUrl(checkoutUrl)) {
            await launchUrl(checkoutUrl, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch payment link')),
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
        appBar: AppBar(title: const Text('Reservation Form')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reservation Form')),
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
