import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<dynamic> payments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.baseUrl + 'get_payments.php'));
      if (response.statusCode == 200) {
        setState(() {
          payments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load payments. Status code: \${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching payments: \$e';
        isLoading = false;
      });
    }
  }

  Widget buildPaymentItem(Map<String, dynamic> payment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text('Payment ID: ${payment['payment_id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reservation ID: ${payment['reservation_id']}'),
            Text('Amount: ₱${payment['amount']}'),
            Text('Status: ${payment['status']}'),
            Text('Method: ${payment['method']}'),
            Text('Created At: ${payment['created_at']}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : payments.isEmpty
                  ? Center(child: Text('No transactions found.'))
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        return buildPaymentItem(payments[index]);
                      },
                    ),
    );
  }
}
