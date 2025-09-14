import 'package:flutter/material.dart';

class page2 extends StatelessWidget {
  const page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking.com'),
        actions: [
          IconButton(icon: Icon(Icons.login), onPressed: () {}),
          IconButton(icon: Icon(Icons.person_add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Main Title Section
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              'A place to call home\non your next adventure',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Search Bar Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Where are you going?',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Check-in date',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Check-out date',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('2 adults · 0 children · 1 room'),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Offers Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Example Offer Cards
          Expanded(
            child: ListView(
              children: [
                OfferCard(
                  title: 'Quick escape, quality time',
                  description: 'Save up to 20% with a Getaway Deal',
                ),
                OfferCard(
                  title: 'Live the dream in a holiday home',
                  description: 'Choose from houses, villas, chalets and more',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Offer Card Widget
class OfferCard extends StatelessWidget {
  final String title;
  final String description;

  const OfferCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: Text('Save on stays')),
          ],
        ),
      ),
    );
  }
}