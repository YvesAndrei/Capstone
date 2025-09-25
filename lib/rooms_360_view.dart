import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
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
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}get_rooms.php"));
      if (response.statusCode == 200) {
        // 👀 see the full JSON returned
        debugPrint('DEBUG get_rooms response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          setState(() => _rooms = List<Map<String, dynamic>>.from(data["rooms"]));
        } else {
          setState(() => _rooms = []);
        }
      } else {
        debugPrint('DEBUG get_rooms status: ${response.statusCode}');
        setState(() => _rooms = []);
      }
    } catch (e) {
      debugPrint("Fetch rooms error: $e");
      setState(() => _rooms = []);
    }
    setState(() => _isLoadingRooms = false);
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    // if already starts with http(s), return as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return "${ApiConfig.baseUrl}$path";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRooms) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_rooms.isEmpty) {
      return const Center(child: Text("No rooms available."));
    }

    return ListView.builder(
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        // match the keys exactly as they’re returned by PHP
        final imageUrl = _fullUrl(room["imagefilepath"]);
        final image360Url = _fullUrl(room["image360filepath"]);

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: (imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image),
            title: Text(room["roomname"] ?? "No name"),
            subtitle: Row(
              children: [
                TextButton(
                  onPressed: imageUrl.isNotEmpty
                      ? () => _showImageDialog(imageUrl)
                      : null,
                  child: const Text("View"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: image360Url.isNotEmpty
                      ? () {
                          debugPrint('DEBUG 360 URL: $image360Url');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PanoramaViewer(imageUrl: image360Url),
                            ),
                          );
                        }
                      : null,
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
