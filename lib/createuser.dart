import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define the ImageCarousel widget here or import it if it's in a separate file
// For simplicity, I'm including it directly in main.dart for this example.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  // List of local asset paths for the carousel images
  // IMPORTANT: You need to add these paths to your pubspec.yaml under 'assets:'
  final List<String> imageUrls = [
    'assets/images/image1.png', // Replace with your actual image paths
    'assets/images/image2.png',
    'assets/images/image3.png',
    'assets/images/image4.png',
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

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(
      Uri.parse("http://192.168.100.238/flutter_api/get_users.php"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          users = jsonData['data'];
        });
      }
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

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
                url = "http://192.168.100.238/flutter_api/create_user.php";
              } else {
                url = "http://192.168.100.238/flutter_api/edit_user.php";
                body["id"] = user['id'].toString();
              }

              final response = await http.post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(body),
              );

              final jsonResponse = json.decode(response.body);

              if (jsonResponse['status'] == 'success') {
                Navigator.pop(context);
                fetchUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(jsonResponse['message'])),
                );
              }
            },
            child: Text(user == null ? "Create" : "Update"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse("http://192.168.100.238/flutter_api/delete_user.php"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"id": id}),
    );

    final jsonResponse = json.decode(response.body);

    if (jsonResponse['status'] == 'success') {
      fetchUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResponse['message'])),
      );
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text("${user['firstname']} ${user['lastname']}"),
        subtitle: Text("Email: ${user['email']}"),
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
      appBar: AppBar(title: Text("User Management")),
      body: Column( // Use a Column to stack the carousel and the user list
        children: [
          Expanded( // Give the carousel a flexible space
            flex: 1, // Adjust this flex value to control carousel height relative to the list
            child: ImageCarousel(),
          ),
          Expanded( // Give the user list a flexible space
            flex: 3, // Adjust this flex value to control list height relative to the carousel
            child: users.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView(children: users.map((u) => _userCard(u)).toList()),
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
}
