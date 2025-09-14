import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chatpage_updated.dart'; // Importing ChatPageUpdated
import 'package:flutter_application_1/globals.dart' as globals; 

class UserSelection extends StatefulWidget {
  final Function(int userId, String userName) onUserSelected;

  UserSelection({required this.onUserSelected});

  @override
  _UserSelectionState createState() => _UserSelectionState();
}

class _UserSelectionState extends State<UserSelection> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      print("Fetching users from API...");
      final response = await http.get(
        Uri.parse("http://192.168.100.238/flutter_api/get_users.php"),
      ).timeout(Duration(seconds: 10));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            users = jsonData['data'];
            isLoading = false;
            errorMessage = null;
          });
          print("Successfully fetched ${users.length} users");
        } else {
          setState(() {
            isLoading = false;
            errorMessage = "Failed to load users: ${jsonData['error'] ?? 'Unknown error'}";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Exception fetching users: $e");
      setState(() {
        isLoading = false;
        errorMessage = "Network error: ${e.toString()}";
      });
    }
  }

  void _navigateToMessages(int userId, String userName) {
    Navigator.of(context).pop(); // Close the user selection dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPageUpdated(
          loggedInUserId: globals.loggedInUserId ?? 0,
          otherUserId: userId,
          otherUserName: userName,
        ),
      ),
    );
  }

  void _retryFetch() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select User"),
      content: Container(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: errorMessage != null
          ? [
              TextButton(
                onPressed: _retryFetch,
                child: Text('Retry'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ]
          : null,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Text('No users found'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text("${user['firstname']} ${user['lastname']}"),
          subtitle: Text("ID: ${user['id']}"),
          onTap: () {
            print("User selected: ${user['id']} - ${user['firstname']} ${user['lastname']}");
            _navigateToMessages(int.parse(user['id']), "${user['firstname']} ${user['lastname']}");
          },
        );
      },
    );
  }
}
