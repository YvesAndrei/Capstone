import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  _PackagesPageState createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  List<dynamic> packages = [];

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    final response = await http.get(
      Uri.parse("http://192.168.100.238/flutter_api/get_packages.php"),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        setState(() {
          packages = jsonData['data'];
        });
      }
    }
  }

  Future<void> _deletePackage(String id) async {
    final response = await http.post(
      Uri.parse("http://192.168.100.238/flutter_api/delete_package.php"),
      body: {"id": id},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        fetchPackages();
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
  }

  void _showPackageForm(BuildContext context, [Map<String, dynamic>? pkg]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: pkg?['name'] ?? '');
    final amenitiesController =
        TextEditingController(text: pkg?['amenities'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(pkg == null ? "Add Package" : "Edit Package"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Package Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter Package Name"
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: amenitiesController,
                    decoration: InputDecoration(
                      labelText: "Amenities (one per line)",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4, // ✅ multi-line input
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final body = {
                  "name": nameController.text,
                  "amenities": amenitiesController.text,
                };

                String url = pkg == null
                    ? "http://192.168.100.238/flutter_api/add_package.php"
                    : "http://192.168.100.238/flutter_api/edit_package.php";

                if (pkg != null) {
                  body["id"] = pkg['id'].toString();
                }

                final response = await http.post(Uri.parse(url), body: body);

                if (response.statusCode == 200) {
                  Navigator.pop(context);
                  fetchPackages();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to save package.")),
                  );
                }
              },
              child: Text(pkg == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  Widget _bootstrapStyleCard(Map<String, dynamic> pkg) {
    final amenities = (pkg['amenities'] as String? ?? '')
        .split('\n')
        .where((a) => a.trim().isNotEmpty)
        .toList();

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 400),
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
                  Text(
                    pkg['name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Amenities:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: amenities
                        .map((a) => Chip(
                              label: Text(a, style: TextStyle(fontSize: 12)),
                              backgroundColor: Colors.blue[50],
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPackageForm(context, pkg),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(pkg['id'].toString()),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this package?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePackage(id);
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: Text("All Packages")),
      body: packages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: isWideScreen ? 2 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
                children: packages
                    .map((pkg) => Center(child: _bootstrapStyleCard(pkg)))
                    .toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPackageForm(context),
        tooltip: "Add Package",
        child: Icon(Icons.add),
      ),
    );
  }
}
