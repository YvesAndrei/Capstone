import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/api.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;

  bool isEditingName = false;
  bool isEditingContact = false;
  bool isChangingPassword = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController miController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Map<String, dynamic>? profile;

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final url = "${ApiConfig.getUserProfile}?user_id=${widget.userId}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          setState(() {
            profile = responseData['data'];
            firstnameController.text = profile!['firstname'] ?? '';
            lastnameController.text = profile!['lastname'] ?? '';
            miController.text = profile!['mi'] ?? '';
            emailController.text = profile!['email'] ?? '';
            contactController.text = profile!['contact'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            profile = null;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${responseData['message'] ?? 'User not found'}")),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (isChangingPassword) {
      if (passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a new password")),
        );
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }
    }

    final data = {
      'user_id': widget.userId,
      'firstname': firstnameController.text,
      'lastname': lastnameController.text,
      'mi': miController.text,
      'email': emailController.text,
      'contact': contactController.text,
      'password': isChangingPassword ? passwordController.text : '',
    };

    try {
      final url = ApiConfig.updateUserProfile;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() {
          isEditingName = false;
          isEditingContact = false;
          isChangingPassword = false;
          passwordController.clear();
          confirmPasswordController.clear();
        });
        fetchProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseData['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        isLoading = true;
      });

      // Upload image to server
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.uploadProfilePicture),
        );
        request.fields['user_id'] = widget.userId.toString();
        request.files.add(await http.MultipartFile.fromPath('profile_picture', pickedFile.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          var respStr = await response.stream.bytesToString();
          var jsonResp = json.decode(respStr);

          if (jsonResp['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture uploaded successfully')),
            );
            // Refresh profile to get new picture URL
            await fetchProfile();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: ${jsonResp['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed with status: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildSectionHeader(IconData icon, String title, Widget actionButton) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        actionButton,
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: isRequired
          ? (value) => value == null || value.isEmpty ? '$label is required' : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Management"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              Icons.person,
                              "Profile Picture",
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Choose File"),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (profile != null && profile!['profile_picture'] != null && profile!['profile_picture'].isNotEmpty)
                                        ? NetworkImage(profile!['profile_picture']) as ImageProvider
                                        : const AssetImage('assets/default_profile.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Name Information Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              Icons.person_outline,
                              "Name Information",
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isEditingName = !isEditingName;
                                  });
                                },
                                child: Text(isEditingName ? "Cancel" : "Edit Name"),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEditableField(
                                    label: "First Name",
                                    controller: firstnameController,
                                    isRequired: true,
                                    enabled: isEditingName,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEditableField(
                                    label: "Middle Name",
                                    controller: miController,
                                    enabled: isEditingName,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEditableField(
                                    label: "Last Name",
                                    controller: lastnameController,
                                    isRequired: true,
                                    enabled: isEditingName,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contact Information Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              Icons.phone,
                              "Contact Information",
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isEditingContact = !isEditingContact;
                                  });
                                },
                                child: Text(isEditingContact ? "Cancel" : "Edit Contact"),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildEditableField(
                                    label: "Phone Number",
                                    controller: contactController,
                                    keyboardType: TextInputType.phone,
                                    enabled: isEditingContact,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildEditableField(
                                    label: "Email Address",
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: isEditingContact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Password Section
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              Icons.lock,
                              "Password",
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isChangingPassword = !isChangingPassword;
                                  });
                                },
                                child: Text(isChangingPassword ? "Cancel" : "Change Password"),
                              ),
                            ),
                            if (isChangingPassword) ...[
                              const SizedBox(height: 16),
                              _buildEditableField(
                                label: "New Password",
                                controller: passwordController,
                                obscureText: true,
                                hintText: "Enter new password",
                              ),
                              const SizedBox(height: 16),
                              _buildEditableField(
                                label: "Confirm Password",
                                controller: confirmPasswordController,
                                obscureText: true,
                                hintText: "Confirm new password",
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Save Changes Button
                    if (isEditingName || isEditingContact || isChangingPassword)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: updateProfile,
                          child: const Text("Save Changes"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
