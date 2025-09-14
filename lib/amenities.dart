import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class amenities extends StatefulWidget {
  const amenities({super.key});

  @override
  _AmenitiesPageState createState() => _AmenitiesPageState();
}

class _AmenitiesPageState extends State<amenities> {
  List<dynamic> amenities = [];

  @override
  void initState() {
    super.initState();
    fetchAmenities();
  }

  Future<void> fetchAmenities() async {
    final response = await http.get(
      Uri.parse("http://192.168.100.238/flutter_api/get_amenities.php"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          amenities = jsonData['data'];
        });
      }
    }
  }

 Future<void> _deleteAmenity(String id) async {
  try {
    final response = await http.post(
      Uri.parse("http://192.168.100.238/flutter_api/delete_amenities.php"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "amenity_id": id,
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        fetchAmenities(); // refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: ${jsonData['message']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: ${response.statusCode}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error occurred: $e")),
    );
  }
}


  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this amenity?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAmenity(id);
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

 void _showAmenityForm([Map<String, dynamic>? amenity]) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: amenity?['name'] ?? '');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(amenity == null ? "Add Amenity" : "Edit Amenity"),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Amenity Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) => value!.isEmpty ? "Enter name" : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            final body = {
              "name": nameController.text,
            };

            String url = amenity == null
                ? "http://192.168.100.238/flutter_api/add_amenities.php"
                : "http://192.168.100.238/flutter_api/edit_amenities.php";

            if (amenity != null) {
              body["amenity_id"] = amenity['amenity_id'].toString();
            }

            final response = await http.post(
              Uri.parse(url),
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
              },
              body: body,
            );

            final jsonData = json.decode(response.body);

            if (response.statusCode == 200 && jsonData['status'] == 'success') {
              Navigator.pop(context);
              fetchAmenities();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(amenity == null ? "Amenity added successfully" : "Amenity updated"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${jsonData['message'] ?? 'Unknown error'}")),
              );
            }
          },
          child: Text(amenity == null ? "Add" : "Update"),
        ),
      ],
    ),
  );
}


  Widget _amenityCard(Map<String, dynamic> amenity) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(amenity['name'], style: TextStyle(fontSize: 18)),
          trailing: Wrap(
            spacing: 12,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showAmenityForm(amenity),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(amenity['amenity_id'].toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Text("Amenities")),
      body: amenities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: isWideScreen ? 2 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: amenities.map((a) => _amenityCard(a)).toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAmenityForm(),
        tooltip: "Add Amenity",
        child: Icon(Icons.add),
      ),
    );
  }
}
