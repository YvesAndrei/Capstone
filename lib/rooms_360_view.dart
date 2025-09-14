import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'panorama_viewer.dart';

class Rooms360View extends StatefulWidget {
  const Rooms360View({super.key});

  @override
  _Rooms360ViewState createState() => _Rooms360ViewState();
}

class _Rooms360ViewState extends State<Rooms360View> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

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

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(child: InteractiveViewer(child: Image.network(imageUrl))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRooms) return const Center(child: CircularProgressIndicator());
    if (_rooms.isEmpty) return const Center(child: Text("No rooms available."));

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
              ],
            ),
          ),
        );
      },
    );
  }
}
