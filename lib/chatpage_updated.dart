import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'config/api.dart';
import 'realtime_chat_container.dart';   // <- NEW Messenger style container

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
  State<ChatPageUpdated> createState() => _ChatPageUpdatedState();
}

class _ChatPageUpdatedState extends State<ChatPageUpdated> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  void addMessage(Map<String, dynamic> msg) {
    setState(() {
      messages.add(msg);
    });
    // auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse(ApiConfig.getMessage).replace(queryParameters: {
  'from_user': widget.loggedInUserId.toString(),
  'to_user': widget.otherUserId.toString(),
     });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            messages = List<Map<String, dynamic>>.from(data['messages']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Connect to Node.js WebSocket server
    channel = WebSocketChannel.connect(Uri.parse(ApiConfig.websocketUrl));

    // Register this user
    channel.sink.add(jsonEncode({
      'type': 'register',
      'userId': widget.loggedInUserId,
    }));

    // Listen for events
    channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      if (decoded['type'] == 'message') {
        addMessage(decoded);
      } else if (decoded['type'] == 'typing') {
        if (decoded['from_user'] == widget.otherUserId) {
          setState(() {
            isTyping = decoded['isTyping'] ?? false;
          });
        }
      }
    });

    // Load existing history
    fetchMessages();
  }

  @override
  void dispose() {
    channel.sink.close();
    textController.dispose();
    scrollController.dispose();
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
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: RealtimeChatContainer(
        messages: messages,
        loggedInUserId: widget.loggedInUserId,
        otherUserId: widget.otherUserId,
        isTyping: isTyping,
        sendMessage: (msg) async {
          _sendMessage(msg);
          // Persist to DB
          await http.post(
            Uri.parse(ApiConfig.sendMessage),
            body: {
              'from_user': msg['from_user'].toString(),
              'to_user': msg['to_user'].toString(),
              'message': msg['message'],
            },
          );
        },
        textController: textController,
        scrollController: scrollController,
      ),
    );
  }
}
