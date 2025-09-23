/// Main entry point for the Mendez Resort and Events Place Flutter application.
///
/// This file contains the root widget (MyApp) and the home page (ResortHomePage)
/// which provides a tabbed interface for browsing packages, catering services,
/// reservation calendar, and amenities. It also handles user login functionality.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'payment_success.dart';
import 'payment_failed.dart';
import '../config/api.dart';
import 'Admin.dart';
import 'CreateAccount.dart';
import 'Staff.dart';
import 'User.dart';
import 'globals.dart' as globals;
import 'page2.dart';
import 'rooms_360_view.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';


// Constants for hardcoded data
const List<Map<String, String>> cateringOffers = [
  {
    'title': 'Wedding',
    'description': 'A wedding pictorial typically involves capturing a variety of photos...',
    'imagePath': 'assets/wedding.jpg',
  },
  {
    'title': 'Birthday',
    'description': 'A birthday is the anniversary of the day someone was born...',
    'imagePath': 'assets/birthday.jpg',
  },
  {
    'title': 'Reunions',
    'description': 'A reunion is a gathering of people who haven\'t seen each other for a long time...',
    'imagePath': 'assets/reunion.jpg',
  },
  {
    'title': 'Christening',
    'description': 'A christening is a religious ceremony...',
    'imagePath': 'assets/christening.jpg',
  },
];

void main() {
  setUrlStrategy(const HashUrlStrategy());
  runApp(MyApp());
}

/// Root widget of the application.
///
/// This widget sets up the MaterialApp with the home page being ResortHomePage.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  title: 'Mendez Resort and Eventsplace',
  theme: ThemeData(
    useMaterial3: true,
    primaryColor: Colors.teal,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.teal.withOpacity(0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.teal.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.teal.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal[800]),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[700]),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    ),
  ),
  initialRoute: '/',
  routes: {
    '/': (context) => const ResortHomePage(),
    '/user-dashboard': (context) => const User(),
  },
  onGenerateRoute: (settings) {
    final uri = Uri.parse(settings.name ?? '');

    if (uri.path == '/payment-success') {
      return MaterialPageRoute(
        builder: (_) => const PaymentSuccessPage(),
        settings: settings,
      );
    }
    if (uri.path == '/payment-failed') {
      return MaterialPageRoute(
        builder: (_) => const PaymentFailedPage(),
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: (_) => const ResortHomePage(),
    );
  },
);

  }
}


/// Home page widget for the Mendez Resort application.
///
/// Displays a tabbed interface with packages, catering, calendar, and amenities.
/// Includes login functionality and a carousel of images.
class ResortHomePage extends StatefulWidget {
  const ResortHomePage({super.key});

  @override
  _ResortHomePageState createState() => _ResortHomePageState();
}

class _ResortHomePageState extends State<ResortHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int? loggedInUserId;

  Future<void> _login(BuildContext context) async {
  final String email = _usernameController.text;
  final String password = _passwordController.text;
  final String url = ApiConfig.login;


  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (responseData['status'] == 'success') {
      // ✅ Save login info to globals
      globals.loggedInUserId = responseData['user_id'] as int?;
      globals.loggedInUserEmail = email;
      globals.loggedInUserRoleId = responseData['roleid'] as int?;

      // Debug print (optional)
      print("User ID: ${globals.loggedInUserId}");
      print("Email: ${globals.loggedInUserEmail}");

      int roleId = responseData['roleid'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );

      Widget nextPage;
      switch (roleId) {
        case 1:
          nextPage = Admin();
          break;
        case 2:
          nextPage = User();
          break;
        case 3:
          nextPage = Staff();
          break;
        default:
          nextPage = page2();
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error connecting to server'),
        backgroundColor: Colors.red,
      ),
    );
  }
}





  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Email'),
                onSubmitted: (_) {
                  Navigator.of(context).pop();
                  _login(context);
                },
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSubmitted: (_) {
                  Navigator.of(context).pop();
                  _login(context);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccount()));
                    },
                    child: Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _login(context);
              },
              child: Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/Mendez.jpg', height: 40, width: 40),
              const SizedBox(width: 10),
              const Text('Mendez Resort and Events Place'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => _showLoginDialog(context),
              child: Text(
                'BOOK NOW',
                style: TextStyle(color: Color.fromARGB(255, 45, 28, 194)),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Package'),
              Tab(text: 'Catering'),
              Tab(text: 'Calendar'),
              Tab(text: 'Amenities'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'STAY WITH COMFORT',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: screenWidth < 650 ? 550 : 630,
                      width: double.infinity,
                      child: Carousel(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Mendez Resort Offers',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 500,
                      child: TabBarView(
                        children: [
                          PackagesTab(),
                          _buildCateringTab(screenWidth),
                          _buildCalendarTab(screenWidth),
                          Rooms360View(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab(double screenWidth) {
    return ReservationCalendar();
  }

  /// Builds the catering tab with a grid of catering offers.
  Widget _buildCateringTab(double screenWidth) {
    return GridView.builder(
      itemCount: cateringOffers.length,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: screenWidth < 600 ? 250 : 400,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final item = cateringOffers[index];
        return OfferCard(
          title: item['title']!,
          description: item['description']!,
          imagePath: item['imagePath']!,
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mendez Resort and Events Place'),
              Text('San Jose del Monte, Philippines'),
              Text('0917 821 9235'),
              Text('emendez4374@gmail.com'),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showLoginDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}

/// A card widget to display an offer with an image, title, and description.
///
/// Used in the catering tab to showcase different catering services.
class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OfferCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(description, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// Tab widget for displaying available packages.
///
/// Fetches packages from the API and displays them in a grid layout.
class PackagesTab extends StatefulWidget {
  const PackagesTab({super.key});

  @override
  _PackagesTabState createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  List<dynamic> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    final url = Uri.parse(ApiConfig.getPackages);

    try {
      final response = await http.get(url);
      print('DEBUG: API response body: ${response.body}'); // Debug print
      final data = json.decode(response.body);

      if (data['success'] == true) {
        print('DEBUG: Number of packages received: ${data['data'].length}'); // Debug print
        setState(() {
          packages = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _bootstrapStyleCard(Map<String, dynamic> pkg) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'assets/Mendez.jpg',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkg['name'] ?? 'Unnamed Package',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    pkg['amenities'] != null && pkg['amenities'].toString().trim().isNotEmpty
                      ? "Inclusions:\n" +
                        pkg['amenities']
                          .toString()
                         .split('\n')
                        .map((a) => "- $a")
                       .join("\n")
      : "No inclusions available",
  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    if (isLoading) return Center(child: CircularProgressIndicator());
    if (packages.isEmpty) return Center(child: Text("No packages available."));

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: isWideScreen ? 2 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 2,
        children: packages.map((pkg) => Center(child: _bootstrapStyleCard(pkg))).toList(),
      ),
    );
  }
}

// --- Carousel Widget ---
class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final List<String> imageUrls = [
    'assets/pict1.jpg',
    'assets/pict2.jpg',
    'assets/pict3.jpg',
    'assets/pict4.jpg',
    'assets/pict5.jpg',
    'assets/Mendez.jpg',
  ];

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % imageUrls.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeIn,
        ).then((_) {
          _startAutoScroll();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(imageUrls.length, (index) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// calendar widget
class ReservationCalendar extends StatefulWidget {
  const ReservationCalendar({super.key});

  @override
  _ReservationCalendarState createState() => _ReservationCalendarState();
}

class _ReservationCalendarState extends State<ReservationCalendar> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _events = {};
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse(ApiConfig.calendarReservations);
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["success"] == true && data["data"] is Map) {
        Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};

        (data["data"] as Map<String, dynamic>).forEach((dateStr, reservations) {
          DateTime date = DateTime.parse(dateStr);
          if (reservations is List) {
            fetchedEvents[date] = reservations.cast<Map<String, dynamic>>();
          }
        });

        setState(() {
          _events = fetchedEvents;
          isLoading = false;
        });
      } else {
        throw Exception("Invalid data format from API");
      }
    } catch (e) {
      print("Error fetching events: $e");
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case "day_tour":
        return Colors.blue;
      case "overnight":
        return Colors.green;
      case "whole_day":
        return Colors.red;
      case "events":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (_) => [], // disable default events
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final events = _getEventsForDay(day);
              if (events.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}'),
                      Wrap(
                        spacing: 2,
                        runSpacing: 2,
                        children: events.map((res) {
                          return Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorForType(res["reservation_type"]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }
              return null;
            },
            markerBuilder: (context, date, events) => null, // remove black dots
          ),
        ),
        const SizedBox(height: 12),
        // 🔹 Legend
        Wrap(
          spacing: 16,
          children: [
            _buildLegendItem(Colors.blue, "Day Tour"),
            _buildLegendItem(Colors.green, "Overnight"),
            _buildLegendItem(Colors.red, "Whole Day"),
            _buildLegendItem(Colors.purple, "Events"),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null)
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay!).map((res) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForType(res["reservation_type"]),
                  ),
                  title: Text("Type: ${res["reservation_type"]}"),
                  subtitle: Text("Status: ${res["status"]}"),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
