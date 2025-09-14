import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String? customerFirstname;
  String? customerLastname;
  String? customerMI;
  String? customerAddress;
  String? customerEmail;
  String? customerContact;
  String? customerPassword;

  Future<void> registerUser() async {
    var url = Uri.parse("http://localhost/flutter_api/register.php");

    try {
      var response = await http
          .post(url, body: {
            "firstname": customerFirstname ?? "",
            "lastname": customerLastname ?? "", 
            "mi": customerMI ?? "",
            "address": customerAddress ?? "",
            "email": customerEmail ?? "",
            "contact": customerContact ?? "",
            "password": customerPassword ?? "",
          })
          .timeout(const Duration(seconds: 5));

      print("Server response: ${response.body}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server: ${response.body}")),
      );
    } catch (e) {
      print("Request failed: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildTextField("First Name:", (value) => customerFirstname = value),
            buildTextField("Last Name:", (value) => customerLastname = value),
            buildTextField("M.I:", (value) => customerMI = value),
            buildTextField("Address:", (value) => customerAddress = value),
            buildTextField("Email:", (value) => customerEmail = value),
            buildTextField("Contact Number:", (value) => customerContact = value),
            buildTextField("Password:", (value) => customerPassword = value, isPassword: true),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text("Create"),
                  onPressed: () {
                    registerUser();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text("Update"),
                  onPressed: () {
                    // Optional: Add update logic here
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text("Delete"),
                  onPressed: () {
                    // Optional: Add delete logic here
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, Function(String) onChanged, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
        ),
        obscureText: isPassword,
        onChanged: (value) {
          setState(() {
            onChanged(value);
          });
        },
      ),
    );
  }
}
