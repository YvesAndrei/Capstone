
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/globals.dart' as globals;
import 'package:intl/intl.dart';
import '../config/api.dart';

class UserReservationsPage extends StatefulWidget {
  const UserReservationsPage({super.key});

  @override
  _UserReservationsPageState createState() => _UserReservationsPageState();
}

class _UserReservationsPageState extends State<UserReservationsPage> {
  List<Map<String, dynamic>> reservations = [];
  int currentPage = 1;
  final int limit = 20;
  bool isLoading = false;
  bool hasMore = true;
  String? statusFilter;
  final ScrollController _scrollController = ScrollController();

  final List<String> statusOptions = ['all', 'pending', 'approved', 'rejected', 'paid', 'refunded'];

  @override
  void initState() {
    super.initState();
    fetchReservations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        fetchReservations();
      }
    });
  }

  Future<void> fetchReservations() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final userId = globals.loggedInUserId ?? 0;
      if (userId == 0) {
        throw Exception("User not logged in");
      }

      String url =
          "http://192.168.100.238/flutter_api/get_user_reservations.php?user_id=$userId&page=$currentPage&limit=$limit";
      if (statusFilter != null && statusFilter != 'all') {
        url += "&status=$statusFilter";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final successValue = data["success"];
        bool isSuccess = false;
        if (successValue is bool) {
          isSuccess = successValue;
        } else if (successValue is int) {
          isSuccess = successValue == 1;
        } else if (successValue is String) {
          isSuccess =
              successValue.toLowerCase() == "true" || successValue == "1";
        }

        if (isSuccess) {
          List<Map<String, dynamic>> fetchedData =
              List<Map<String, dynamic>>.from(data["data"] ?? []);

          setState(() {
            currentPage++;
            reservations.addAll(fetchedData);
            hasMore = reservations.length < (data["total"] ?? 0);
          });
        } else {
          throw Exception("API returned success = false");
        }
      } else {
        throw Exception("HTTP error ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading reservations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading reservations: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> refreshData() async {
    setState(() {
      reservations.clear();
      currentPage = 1;
      hasMore = true;
    });
    await fetchReservations();
  }

  void onStatusFilterChanged(String? newStatus) {
    if (newStatus == null) return;
    setState(() {
      statusFilter = newStatus == 'all' ? null : newStatus;
      reservations.clear();
      currentPage = 1;
      hasMore = true;
    });
    fetchReservations();
  }

  Widget buildReservationCard(Map<String, dynamic> reservation) {
    final int reservationId = int.parse(reservation["id"].toString());
    final String status = reservation["status"] ?? "N/A";

    Color statusColor;
    switch (status) {
      case "approved":
        statusColor = Colors.green;
        break;
      case "pending":
        statusColor = Colors.orange;
        break;
      case "rejected":
        statusColor = Colors.red;
        break;
      case "paid":
        statusColor = Colors.green;
        break;
      case "refunded":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Parse and format created_at date
    String requestedDateStr = "N/A";
    if (reservation["created_at"] != null) {
      try {
        DateTime requestedDate = DateTime.parse(reservation["created_at"]);
        requestedDateStr =
            DateFormat('MMM dd, yyyy HH:mm').format(requestedDate);
      } catch (e) {
        requestedDateStr = reservation["created_at"];
      }
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservation #$reservationId",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text("Package ID: ${reservation["package_id"] ?? "N/A"}"),
            Text("Type: ${reservation["reservation_type"] ?? "N/A"}"),
            Text("Date: ${reservation["date"] ?? "N/A"}"),
            Text("Requested Date: $requestedDateStr"),
            Text("Guests: ${reservation["guest_count"]?.toString() ?? "N/A"}"),
            Text("Amount: ₱${reservation["total_amount"]?.toString() ?? "0.00"}"),
            Row(
              children: [
                Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (status == "paid")
              ElevatedButton(
                onPressed: () {
                  requestRefund(reservationId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Request Refund"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> requestRefund(int reservationId) async {
  try {
    final res = await http.post(
      Uri.parse(ApiConfig.requestRefund),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'reservation_id': reservationId,
        // Optionally add: 'reason': 'Customer changed plans'
      }),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Refund request sent to admin."), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to request refund: ${data['error'] ?? 'Unknown error'}"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("HTTP error: ${res.statusCode}"), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error requesting refund: $e"), backgroundColor: Colors.red),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Reservations"),
        actions: [
          DropdownButton<String>(
            value: statusFilter ?? 'all',
            items: statusOptions
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                          status[0].toUpperCase() + status.substring(1)),
                    ))
                .toList(),
            onChanged: onStatusFilterChanged,
            underline: Container(),
            dropdownColor: Colors.blue,
            style: TextStyle(color: Colors.white, fontSize: 16),
            iconEnabledColor: Colors.white,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: reservations.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < reservations.length) {
              return buildReservationCard(reservations[index]);
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
