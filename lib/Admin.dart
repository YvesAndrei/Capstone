import 'package:flutter/material.dart';
import 'packages_page.dart';
import 'amenities.dart';
import 'createuser.dart';
import 'manage_reservations.dart';
import 'chatpage_updated.dart';
import 'user_selection.dart';
import 'main.dart';
import 'package:flutter_application_1/globals.dart' as globals;
import 'uploads_page.dart';
import 'transaction_page.dart';
import 'user_approvals.dart';
import 'reservation_calendar.dart' as rc;

/// Admin dashboard widget for managing resort operations.
class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String selectedPage = 'dashboard';
  
  Widget _buildMainContent() {
    switch (selectedPage) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'settings':
        return _buildSettingsContent();
      case 'amenities':
        return amenities();
      case 'packages':
        return PackagesPage();
      case 'transacts':
        return const TransactionPage();
      case '360view':
        return const UploadsPage();
      case 'message':
        return _buildMessageContent();
      case 'createuser':
        return CreateUserPage();
      case 'userapprovals':
        return UserApprovalsPage();
      case 'manageres':
        return ManageReservationsPage();
      default:
        return _buildDashboardContent();
    }
  }

    Widget _buildDashboardContent() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green header container
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Resort Management Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 30),
          Text(
            'Select an option from the sidebar to manage your resort operations.',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          SizedBox(height: 30),

          // 👇 Add the calendar here
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, // background for calendar
                borderRadius: BorderRadius.circular(12),
              ),
              child: rc.ReservationCalendar(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSettingsContent() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person, color: Colors.white),
            title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: () {
              // Add profile settings functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Messages',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => UserSelection(
                  onUserSelected: (userId, userName) {
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
                  },
                ),
              );
            },
            child: Text('Start New Conversation'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String pageKey) {
    bool isSelected = selectedPage == pageKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPage = pageKey;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        margin: EdgeInsets.symmetric(vertical: 2.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/Mendez.jpg', height: 30, width: 30),
            SizedBox(width: 10),
            Text('Admin Dashboard'),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Admin()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
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
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/Mendez.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Content
          Row(
            children: [
              // Left sidebar menu
              Container(
                width: 200,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildMenuItem('Dashboard', 'dashboard'),
                    _buildMenuItem('Settings', 'settings'),
                    _buildMenuItem('Amenities', 'amenities'),
                    _buildMenuItem('Packages', 'packages'),
                    _buildMenuItem('Transaction', 'transacts'),
                    _buildMenuItem('Upload 360 Viewing', '360view'),
                    SizedBox(height: 20),
                    _buildMenuItem('Messages', 'message'),
                    _buildMenuItem('Create Users', 'createuser'),
                    _buildMenuItem('User Approvals', 'userapprovals'),
                    _buildMenuItem('Manage Reservations', 'manageres'),
                  ],
                ),
              ),
              // Main content area
              Expanded(
                child: _buildMainContent(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
