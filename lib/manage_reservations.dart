import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';

class ManageReservationsPage extends StatefulWidget {
  const ManageReservationsPage({super.key});

  @override
  _ManageReservationsPageState createState() => _ManageReservationsPageState();
}

class _ManageReservationsPageState extends State<ManageReservationsPage> {
  List<Map<String, dynamic>> reservations = [];
  int currentPage = 1;
  final int limit = 20;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

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
      final response = await http.get(
        Uri.parse("${ApiConfig.getReservations}?page=$currentPage&limit=$limit"),
      );

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
    }

    setState(() => isLoading = false);
  }

  Future<void> updateReservationStatus(
      int reservationId, String newStatus) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.updateReservationStatus),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'reservation_id': reservationId,
          'status': newStatus,
        }),
      );

      if (res.statusCode == 200) {
        final responseData = json.decode(res.body);
        if (responseData['success'] == true) {
          setState(() {
            final index = reservations.indexWhere(
              (r) => int.parse(r["id"].toString()) == reservationId,
            );
            if (index != -1) {
              reservations[index]["status"] = newStatus;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Reservation $newStatus successfully!"),
              backgroundColor:
                  newStatus == "approved" ? Colors.green : Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update reservation."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("HTTP error: ${res.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error updating reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating reservation."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> adminRefund(int reservationId) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.adminRefund),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'reservation_id': reservationId}),
      );

      if (res.statusCode == 200) {
        final responseData = json.decode(res.body);
        if (responseData['success'] == true) {
          setState(() {
            final index = reservations.indexWhere(
              (r) => int.parse(r["id"].toString()) == reservationId,
            );
            if (index != -1) {
              reservations[index]["status"] = "refunded";
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Refund processed successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Refund failed: ${responseData['error']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error processing refund: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing refund."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showConfirmDialog(int reservationId, String action,
      {bool isRefund = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${action[0].toUpperCase()}${action.substring(1)} Reservation"),
          content: Text("Are you sure you want to $action this reservation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isRefund) {
                  adminRefund(reservationId);
                } else {
                  updateReservationStatus(reservationId, action);
                }
              },
              child: Text(action[0].toUpperCase() + action.substring(1)),
            ),
          ],
        );
      },
    );
  }

  Widget buildReservationCard(Map<String, dynamic> reservation) {
    final int reservationId = int.parse(reservation["id"].toString());
    final String status = reservation["status"] ?? "N/A";

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reservation #$reservationId",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("User ID: ${reservation["user_id"] ?? "N/A"}"),
            Text("Package ID: ${reservation["package_id"] ?? "N/A"}"),
            Text("Type: ${reservation["reservation_type"] ?? "N/A"}"),
            Text("Date: ${reservation["date"] ?? "N/A"}"),
            Text("Guests: ${reservation["guest_count"]?.toString() ?? "N/A"}"),
            Text("Amount: ₱${reservation["total_amount"]?.toString() ?? "0.00"}"),
            Text("Status: $status"),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: (status == "pending" || status == "paid")
                      ? () => showConfirmDialog(reservationId, "approved")
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Approve"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (status == "pending") {
                      showConfirmDialog(reservationId, "refunded");
                    } else if (status == "paid") {
                      showConfirmDialog(reservationId, "refunded", isRefund: true);
                    } else {
                      null;
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(status == "paid"
                      ? "Reject & Refund"
                      : status == "pending"
                          ? "Reject"
                          : "Refund"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> refreshData() async {
    setState(() {
      reservations.clear();
      currentPage = 1;
      hasMore = true;
    });
    await fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Reservations")),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: reservations.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < reservations.length) {
              return buildReservationCard(reservations[index]);
            } else {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
