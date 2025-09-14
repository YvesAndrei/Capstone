import 'package:flutter/material.dart';
import 'packages_page.dart';
import 'amenities.dart';
import 'createuser.dart';
import 'manage_reservations.dart'; // NEW import
import 'chatpage_updated.dart'; // Updated import for enhanced messaging
import 'user_selection.dart'; // Import the new user selection component
import 'main.dart'; // Import main.dart for ResortHomePage
import 'package:flutter_application_1/globals.dart' as globals; // Import globals for session management
import 'uploads_page.dart'; // NEW

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Amenities'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => amenities()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Packages'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PackagesPage()),
                );
              },
             ),
              ListTile(
                leading: Icon(Icons.upload_file),
                title: Text('Upload 360 Viewing'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadsPage()),
                  );
  },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
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
            )

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              direction: Axis.vertical,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.message, size: 30),
                  label: Text('Messages', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  onPressed: () {
                    print("Messages button tapped - opening user selection");
                    showDialog(
                      context: context,
                      builder: (context) => UserSelection(
                        onUserSelected: (userId, userName) {
                          print("User selected - ID: \$userId, Name: \$userName");
                          print("Navigating to ChatPageUpdated...");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPageUpdated(
                                loggedInUserId: globals.loggedInUserId ?? 0,
                                otherUserId: userId,
                                otherUserName: userName,
                              ),
                            ),
                          ).then((_) {
                            print("Navigation to chat page completed");
                          }).catchError((error) {
                            print("Navigation error: \$error");
                          });
                        },
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.people, size: 30),
                  label: Text('Create Users', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateUserPage()),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.assignment, size: 30),
                  label: Text('Manage Reservations', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageReservationsPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text('Welcome, Admin!'),
            ),
          ],
        ),
      ),
    );
  }
}
