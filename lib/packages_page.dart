import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

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
      body: {"package_type_id": id},
    );

    print("DELETE RESPONSE: ${response.body}");

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

  Widget _formField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  void _showPackageForm(BuildContext context, [Map<String, dynamic>? pkg]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: pkg?['package_name'] ?? '');
    final typeController = TextEditingController(text: pkg?['day_type'] ?? '');
    final scheduleController = TextEditingController(text: pkg?['week_schedule'] ?? '');
    final hoursController = TextEditingController(text: pkg?['hours']?.toString() ?? '');
    final priceController = TextEditingController(text: pkg?['price']?.toString() ?? '');
    final amenitiesController = TextEditingController(text: pkg?['amenities_id']?.toString() ?? '');

    final dayTypeOptions = ['Day Tour', 'Overnight'];
    final weekScheduleOptions = ['Weekend', 'Weekday'];
    final hoursOptions = ['9 Hours', '21 Hours'];

    String selectedDayType = pkg?['day_type'] ?? dayTypeOptions[0];
    String selectedWeekSchedule = pkg?['week_schedule'] ?? weekScheduleOptions[0];
    String selectedHours = pkg?['hours']?.toString() ?? hoursOptions[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(pkg == null ? "Add Package" : "Edit Package"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _formField("Package Name", nameController),

                      DropdownButtonFormField<String>(
                        value: selectedDayType,
                        decoration: InputDecoration(
                          labelText: "Day Type",
                          border: OutlineInputBorder(),
                        ),
                        items: dayTypeOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedDayType = val;
                              typeController.text = val;
                            });
                          }
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? "Select Day Type" : null,
                      ),

                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedWeekSchedule,
                        decoration: InputDecoration(
                          labelText: "Week Schedule",
                          border: OutlineInputBorder(),
                        ),
                        items: weekScheduleOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedWeekSchedule = val;
                              scheduleController.text = val;
                            });
                          }
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? "Select Week Schedule" : null,
                      ),

                      SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedHours,
                        decoration: InputDecoration(
                          labelText: "Hours",
                          border: OutlineInputBorder(),
                        ),
                        items: hoursOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedHours = val;
                              hoursController.text = val;
                            });
                          }
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? "Select Hours" : null,
                      ),

                      SizedBox(height: 12),

                      _formField("Price", priceController, inputType: TextInputType.number),
                      _formField("Amenities ID", amenitiesController, inputType: TextInputType.number),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final body = {
                      "package_name": nameController.text,
                      "day_type": typeController.text,
                      "week_schedule": scheduleController.text,
                      "hours": hoursController.text,
                      "price": priceController.text,
                      "amenities_id": amenitiesController.text,
                    };

                    String url = pkg == null
                        ? "http://192.168.100.238/flutter_api/add_package.php"
                        : "http://192.168.100.238/flutter_api/edit_package.php";

                    if (pkg != null) {
                      body["package_type_id"] = pkg['package_type_id'].toString();
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
      },
    );
  }

  Widget _bootstrapStyleCard(Map<String, dynamic> pkg) {
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
                    pkg['package_name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${pkg['day_type']} - ${pkg['week_schedule']}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Text('Hours: ${pkg['hours']}'),
                  Text('Price: ₱${pkg['price']}'),
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
                        onPressed: () => _confirmDelete(pkg['package_type_id'].toString()),
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
