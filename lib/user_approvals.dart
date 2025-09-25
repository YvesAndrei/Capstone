import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api.dart';
class UserApprovalsPage extends StatefulWidget {
  const UserApprovalsPage({super.key});

  @override
  _UserApprovalsPageState createState() => _UserApprovalsPageState();
}

class _UserApprovalsPageState extends State<UserApprovalsPage> {
  List<dynamic> pendingUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingUsers();
  }

  Future<void> fetchPendingUsers() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.getPendingUsers));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            pendingUsers = data['users'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> approveUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.approveUser),
        body: {'user_id': userId.toString()},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User approved')));
          fetchPendingUsers(); // Refresh list
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> rejectUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.rejectUser),
        body: {'user_id': userId.toString()},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User rejected')));
          fetchPendingUsers(); // Refresh list
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Approvals')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pendingUsers.isEmpty
              ? Center(child: Text('No pending users'))
              : ListView.builder(
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = pendingUsers[index];
                    return ListTile(
                      title: Text('${user['firstname']} ${user['lastname']}'),
                      subtitle: Text(user['email']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => approveUser(user['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => rejectUser(user['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
