import 'package:flutter/material.dart';
import 'chatpage_updated.dart'; // Updated import for enhanced messaging
import 'package:flutter_application_1/globals.dart' as globals; // Use globals for user data
import 'main.dart'; // Import main.dart for ResortHomePage

class Staff extends StatelessWidget {
  const Staff({super.key});

  @override
  Widget build(BuildContext context) {
    final int currentUserId = globals.loggedInUserId ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Mendez.jpg', height: 40, width: 40),
            const SizedBox(width: 10),
            const Text('Staff Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Staff()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Staff Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // --- Messaging Drawer Tile ---
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPageUpdated(
                      loggedInUserId: currentUserId,
                      otherUserId: 1, // Admin ID as int
                      otherUserName: 'Admin',
                    ),
                  ),
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
            ),
          ],
        ),
      ),
      body: Center(child: Text('Welcome, Staff!')),
    );
  }
}
