import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Tabs Example',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Matching your app bar color
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the number of tabs
    _tabController = TabController(length: 3, vsync: this); // 3 tabs: Home, Settings, Profile
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('gawa ni Eves'),
        // Add the TabBar to the bottom of the AppBar
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.person), text: 'About us'),
          ],
          labelColor: const Color.fromARGB(255, 98, 39, 174), // Color of selected tab icon/text
          unselectedLabelColor: const Color.fromARGB(255, 61, 219, 12), // Color of unselected tab icon/text
          indicatorColor: const Color.fromARGB(255, 224, 202, 9), // Color of the underline indicator
        ),
      ),
      
      
      // Add a Drawer to the Scaffold
      // The body of the Scaffold will be the TabBarView
      body: TabBarView(
        controller: _tabController,
        children: [
          // Content for the Home tab 
          Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Home Content Here',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: 0.8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/Mendez.jpg')
                    ),
                  ),
                  Opacity(
                    opacity: 0.3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/cat.jpg')
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Content for the Settings tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [ 
                Icon(Icons.warning, size: 60, color: Color.fromARGB(255, 218, 241, 11)),
                SizedBox(height: 16),
                Text(
                  'Settings Content Here',
                
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  'Bwakananginamo'
                  'Eves'
                  'Kupal',
                  style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 98, 39, 174), fontFamily: 'Arial', fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          // Content for the Profile tab
Align(
  alignment: Alignment.topLeft,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Profile Content Here',
   
        ),
    
      Text(
        'Eves',
   
      ),
    ],
  ),
),
        ],
      ),
      
      drawer: Drawer(
        child: ListView(
          
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Header (Optional: for user info or app branding)
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'My Kupal Drawer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Clickable Drawer Item 1: Home
            ListTile(
              leading: const Icon(Icons.home), // Icon on the left
              title: const Text('Home'), // Text of the item
              onTap: () {
                // Action when 'Home' is tapped
                // Pop the drawer if we're not already on the home screen
                // or if you want to explicitly close it.
                Navigator.pop(context); // Close the drawer
                // If you are already on the home screen, you might not need to do anything
                // or you could navigate to '/' if using named routes and ensure it's the root
                // Navigator.pushReplacementNamed(context, '/'); // Example: if home is your root
              },
            ),
            // Clickable Drawer Item 2: Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Action when 'Settings' is tapped
                Navigator.pop(context); // Close the drawer first
                Navigator.pushNamed(context, '/settings'); // Navigate to SettingsScreen
              },
            ),
            // Clickable Drawer Item 3: About
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                // Action when 'About' is tapped
                Navigator.pop(context); // Close the drawer first
                Navigator.pushNamed(context, '/about'); // Navigate to AboutScreen
              },
            ),
            const Divider(), // A visual separator
            // Another example: just a text button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the drawer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged Out!')),
                  );
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
       
      // You can keep your FloatingActionButton if needed
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action for the FAB
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}