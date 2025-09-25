import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api.dart';

// Define the ImageCarousel widget here or import it if it's in a separate file
// For simplicity, I'm including it directly in main.dart for this example.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // List of local asset paths for the carousel images using actual assets from pubspec.yaml
  final List<String> imageUrls = [
    'assets/pict1.jpg',
    'assets/pict2.jpg',
    'assets/pict3.jpg',
    'assets/pict4.jpg',
  ];

  // Controller for the PageView to manage pages
  final PageController _pageController = PageController(initialPage: 0);
  // Current page index
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Optional: Auto-scroll the carousel
    // Uncomment the line below and the _startAutoScroll method to enable
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _startAutoScroll();
    // });
  }

  // Function to start auto-scrolling (uncomment to enable)
  // void _startAutoScroll() {
  //   Future.delayed(Duration(seconds: 3)).then((_) {
  //     if (_pageController.hasClients) {
  //       int nextPage = (_currentPage + 1) % imageUrls.length;
  //       _pageController.animateToPage(
  //         nextPage,
  //         duration: Duration(milliseconds: 400),
  //         curve: Curves.easeIn,
  //       ).then((_) {
  //         _startAutoScroll(); // Continue auto-scrolling
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2, // Give more space to the carousel
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page; // Update current page indicator
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0), // Rounded corners for images
                  child: Image.asset( // Use Image.asset for local images
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red, size: 50),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imageUrls.length, (index) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.blueAccent // Active dot color
                    : Colors.grey, // Inactive dot color
              ),
            );
          }),
        ),
        SizedBox(height: 10), // Spacing below dots
      ],
    );
  }
}


class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    // Auto-refresh every 30 seconds to keep data synchronized
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        fetchUsers();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Connect to your local database
      final response = await http.get(
        Uri.parse(ApiConfig.getUsers),

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            users = jsonData['data'] ?? [];
            isLoading = false;
          });
          print('Successfully loaded ${users.length} users from database');
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load users');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        errorMessage = 'Failed to connect to database: ${e.toString()}';
        isLoading = false;
        users = []; // Empty list if database connection fails
      });
    }
  }

  Future<void> createOrUpdateUser({Map<String, dynamic>? user}) async {
    final formKey = GlobalKey<FormState>();
    final firstnameController = TextEditingController(text: user?['firstname']);
    final lastnameController = TextEditingController(text: user?['lastname']);
    final miController = TextEditingController(text: user?['mi']);
    final addressController = TextEditingController(text: user?['address']);
    final emailController = TextEditingController(text: user?['email']);
    final contactController = TextEditingController(text: user?['contact']);
    final passwordController = TextEditingController(text: user?['password']);
    final roleidController = TextEditingController(text: user?['roleid']?.toString() ?? '2');

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? "Create User" : "Edit User"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _textField("First Name", firstnameController),
                  _textField("Last Name", lastnameController),
                  _textField("Middle Initial", miController),
                  _textField("Address", addressController),
                  _textField("Email", emailController),
                  _textField("Contact", contactController),
                  _textField("Password", passwordController, obscureText: true),
                  _textField("Role ID", roleidController),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context), 
              child: Text("Cancel")
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (!formKey.currentState!.validate()) return;

                setState(() {
                  isSubmitting = true;
                });

                try {
                  final Map<String, String> body = {
                    "firstname": firstnameController.text,
                    "lastname": lastnameController.text,
                    "mi": miController.text,
                    "address": addressController.text,
                    "email": emailController.text,
                    "contact": contactController.text,
                    "password": passwordController.text,
                    "roleid": roleidController.text,
                  };

                  String url;
                  if (user == null) {
                    url = ApiConfig.createUser;
                  } else {
                    url = ApiConfig.editUser;
                    body["id"] = user['id'].toString();
                  }


                  final response = await http.post(
                    Uri.parse(url),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                    body: json.encode(body),
                  ).timeout(const Duration(seconds: 10));

                  final jsonResponse = json.decode(response.body);

                  if (jsonResponse['status'] == 'success') {
                    Navigator.pop(context);
                    fetchUsers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(user == null ? 'User created successfully!' : 'User updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(jsonResponse['message'] ?? 'Operation failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Network error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    isSubmitting = false;
                  });
                }
              },
              child: isSubmitting 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(user == null ? "Create" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.deleteUser),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({"id": id}),
      ).timeout(const Duration(seconds: 10));

      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed. Please check your network and try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print('deleteUser error: $e');
    }
  }

  Widget _textField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    // Get role name based on roleid
    String getRoleName(String roleId) {
      switch (roleId) {
        case '1': return 'Admin';
        case '2': return 'User';
        case '3': return 'Staff';
        default: return 'Unknown';
      }
    }

    // Get verification status
    String getVerificationStatus(String verified) {
      return verified == '1' ? 'Verified' : 'Not Verified';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("${user['firstname']} ${user['lastname']}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${user['email']}"),
            Text("Contact: ${user['contact']}"),
            Text("Role: ${getRoleName(user['roleid'])} | ${getVerificationStatus(user['verified'])}"),
            Text("ID: ${user['id']}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => createOrUpdateUser(user: user),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(user['id'].toString()),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete User"),
        content: Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUser(id);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,
            tooltip: 'Refresh Users',
          ),
        ],
      ),
      body: Column( // Use a Column to stack the carousel and the user list
        children: [
          Expanded( // Give the carousel a flexible space
            flex: 1, // Adjust this flex value to control carousel height relative to the list
            child: ImageCarousel(),
          ),
          Expanded( // Give the user list a flexible space
            flex: 3, // Adjust this flex value to control list height relative to the carousel
            child: _buildUserList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createOrUpdateUser(),
        tooltip: "Create User",
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchUsers,
              child: Text('Try Server Connection'),
            ),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => createOrUpdateUser(),
              child: Text('Create First User'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Add a banner to show database connection status
        if (users.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.green.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_done, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Live Database - ${users.length} users loaded',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchUsers,
            child: ListView(
              children: users.map((u) => _userCard(u)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
