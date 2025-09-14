import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:panorama/panorama.dart';
import 'panorama_viewer.dart';
import 'package:flutter_application_1/globals.dart' as globals;

class UploadsPage extends StatefulWidget {
  const UploadsPage({super.key});

  @override
  _UploadsPageState createState() => _UploadsPageState();
}

class _UploadsPageState extends State<UploadsPage> with SingleTickerProviderStateMixin {
  final picker = ImagePicker();

  String _roomName = "";
  String _poolName = "";

  XFile? _pickedImage;
  XFile? _pickedImage360;

  File? _imageFile;
  File? _image360File;

  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _pools = [];
  bool _isLoadingRooms = false;
  bool _isLoadingPools = false;

  late TabController _tabController;

  bool get isAdmin => globals.loggedInUserRoleId == 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRooms();
    _fetchPools();
  }

  // ---------------- Fetch Rooms ----------------
  Future<void> _fetchRooms() async {
    setState(() => _isLoadingRooms = true);
    try {
      final response = await http.get(Uri.parse("http://192.168.100.238/flutter_api/get_rooms.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() => _rooms = List<Map<String, dynamic>>.from(data["rooms"]));
        } else {
          setState(() => _rooms = []);
        }
      }
    } catch (e) {
      print("Fetch rooms error: $e");
    }
    setState(() => _isLoadingRooms = false);
  }

  // ---------------- Fetch Pools ----------------
  Future<void> _fetchPools() async {
    setState(() => _isLoadingPools = true);
    try {
      final response = await http.get(Uri.parse("http://192.168.100.238/flutter_api/get_pools.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() => _pools = List<Map<String, dynamic>>.from(data["pools"]));
        } else {
          setState(() => _pools = []);
        }
      }
    } catch (e) {
      print("Fetch pools error: $e");
    }
    setState(() => _isLoadingPools = false);
  }

  // ---------------- Pick Image ----------------
  Future<void> _pickImage(bool is360) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (is360) {
          _image360File = kIsWeb ? null : File(pickedFile.path);
          _pickedImage360 = pickedFile;
        } else {
          _imageFile = kIsWeb ? null : File(pickedFile.path);
          _pickedImage = pickedFile;
        }
      });
    }
  }

  // ---------------- Upload Rooms ----------------
  Future<void> _uploadRoom() async {
    if (_roomName.isEmpty || _pickedImage == null || _pickedImage360 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields and select both images")));
      return;
    }

    await _uploadItem(
      tableName: "room",
      nameField: "roomname",
      nameValue: _roomName,
    );
    _fetchRooms();
  }

  // ---------------- Upload Pools ----------------
  Future<void> _uploadPool() async {
    if (_poolName.isEmpty || _pickedImage == null || _pickedImage360 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields and select both images")));
      return;
    }

    await _uploadItem(
      tableName: "pool",
      nameField: "poolname",
      nameValue: _poolName,
    );
    _fetchPools();
  }

  // ---------------- Generic Upload ----------------
  Future<void> _uploadItem({required String tableName, required String nameField, required String nameValue}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(tableName == "room" ? "http://192.168.100.238/flutter_api/upload_room.php" : "http://192.168.100.238/flutter_api/upload_pool.php"),
    );
    request.fields[nameField] = nameValue;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('image', await _pickedImage!.readAsBytes(), filename: _pickedImage!.name));
      request.files.add(http.MultipartFile.fromBytes('image360', await _pickedImage360!.readAsBytes(), filename: _pickedImage360!.name));
    } else {
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
      request.files.add(await http.MultipartFile.fromPath('image360', _image360File!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload successful!")));
      Navigator.pop(context);
      setState(() {
        _imageFile = null;
        _image360File = null;
        _pickedImage = null;
        _pickedImage360 = null;
        _roomName = "";
        _poolName = "";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: ${response.statusCode}")));
    }
  }

  // ---------------- Dialog ----------------
  void _openAddDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text("Add ${type == 'room' ? 'Room' : 'Pool'}"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: type == 'room' ? "Room Name" : "Pool Name"),
                    onChanged: (value) => setModalState(() {
                      if (type == 'room') _roomName = value;
                      if (type == 'pool') _poolName = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(icon: const Icon(Icons.image), label: const Text("Pick Normal Image"), onPressed: () => _pickImage(false)),
                  if (_pickedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: kIsWeb ? FutureBuilder<Uint8List>(future: _pickedImage!.readAsBytes(), builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!, height: 100) : const SizedBox()) : Image.file(_imageFile!, height: 100),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(icon: const Icon(Icons.threesixty), label: const Text("Pick 360° Image"), onPressed: () => _pickImage(true)),
                  if (_pickedImage360 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: kIsWeb ? FutureBuilder<Uint8List>(future: _pickedImage360!.readAsBytes(), builder: (context, snapshot) => snapshot.hasData ? Image.memory(snapshot.data!, height: 100) : const SizedBox()) : Image.file(_image360File!, height: 100),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
              ElevatedButton(child: const Text("Save"), onPressed: () => type == 'room' ? _uploadRoom() : _uploadPool()),
            ],
          );
        });
      },
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Uploads"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Rooms"),
              Tab(text: "Pools"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRoomsTab(),
            _buildPoolsTab(),
          ],
        ),
        floatingActionButton: isAdmin ? FloatingActionButton(
          onPressed: () => _openAddDialog(_tabController.index == 0 ? 'room' : 'pool'),
          child: const Icon(Icons.add),
        ) : null,
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoadingRooms) return const Center(child: CircularProgressIndicator());
    if (_rooms.isEmpty) return const Center(child: Text("No rooms yet. Add one using the button below."));

    return ListView.builder(
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: room["imagefilepath"] != null
                ? Image.network("http://192.168.100.238/flutter_api/${room["imagefilepath"]}", width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(room["roomname"] ?? "No name"),
            subtitle: Row(
              children: [
                TextButton(
                  onPressed: () => _showImageDialog("http://192.168.100.238/flutter_api/${room["imagefilepath"]}"),
                  child: const Text("View"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PanoramaViewer(imageUrl: "http://192.168.100.238/flutter_api/${room["image360filepath"]}")),
                    );
                  },
                  child: const Text("View 360°"),
                ),
                const SizedBox(width: 8),
                if (isAdmin) IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: const Text("Are you sure you want to delete this room?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final intId = int.tryParse(room["id"].toString()) ?? 0;
                      if (intId > 0) {
                        await _deleteRoom(intId);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid room id")));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isDeleting = false;

  Future<void> _deleteRoom(int id) async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });
    final url = Uri.parse("http://192.168.100.238/flutter_api/delete_room.php");
    try {
      print("Sending delete request for room id: $id");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      print("Delete response status: ${response.statusCode}");
      print("Delete response body: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() {
            _rooms.removeWhere((room) => room["id"] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Room deleted successfully")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: ${data["message"]}")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete error: $e")));
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Widget _buildPoolsTab() {
    if (_isLoadingPools) return const Center(child: CircularProgressIndicator());
    if (_pools.isEmpty) return const Center(child: Text("No pools yet. Add one using the button below."));

    return ListView.builder(
      itemCount: _pools.length,
      itemBuilder: (context, index) {
        final pool = _pools[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: pool["imagefilepath"] != null
                ? Image.network("http://192.168.100.238/flutter_api/${pool["imagefilepath"]}", width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(pool["poolname"] ?? "No name"),
            subtitle: Row(
              children: [
                TextButton(
                  onPressed: () => _showImageDialog("http://192.168.100.238/flutter_api/${pool["imagefilepath"]}"),
                  child: const Text("View"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PanoramaViewer(imageUrl: "http://192.168.100.238/flutter_api/${pool["image360filepath"]}")),
                    );
                  },
                  child: const Text("View 360°"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
