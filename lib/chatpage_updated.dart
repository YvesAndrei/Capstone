import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'realtime_chat_container.dart';
import 'config/api.dart'; // Make sure ApiConfig.websocketUrl is here

class ChatPageUpdated extends StatefulWidget {
  final int loggedInUserId;
  final int otherUserId;
  final String otherUserName;

  const ChatPageUpdated({
    Key? key,
    required this.loggedInUserId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  _ChatPageUpdatedState createState() => _ChatPageUpdatedState();
}

class _ChatPageUpdatedState extends State<ChatPageUpdated> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();

    // connect to your Node.js server
    channel = WebSocketChannel.connect(Uri.parse(ApiConfig.websocketUrl));

    // register this user with the server
    channel.sink.add(jsonEncode({
      'type': 'register',
      'userId': widget.loggedInUserId,
    }));

    // listen for messages
    channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      if (decoded['type'] == 'message') {
        setState(() {
          messages.add(decoded);
        });
      } else if (decoded['type'] == 'typing') {
        // only show typing if it's from the other user
        if (decoded['from_user'] == widget.otherUserId) {
          setState(() {
            isTyping = decoded['isTyping'] ?? false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendMessage(Map<String, dynamic> msg) {
    channel.sink.add(jsonEncode(msg));
  }

  void _sendTypingStatus(Map<String, dynamic> status) {
    channel.sink.add(jsonEncode(status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: RealtimeChatContainer(
        loggedInUserId: widget.loggedInUserId,
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        messages: messages,
        isTyping: isTyping,
        sendMessage: _sendMessage,
        sendTypingStatus: _sendTypingStatus,
      ),
    );
  }
}
