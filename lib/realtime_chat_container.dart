import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api.dart';

class RealtimeChatContainer extends StatefulWidget {
  final int loggedInUserId;
  final int otherUserId;
  final String otherUserName;
  final List<Map<String, dynamic>> messages;
  final bool isTyping;
  final void Function(Map<String, dynamic>) sendMessage;
  final void Function(Map<String, dynamic>) sendTypingStatus;

  RealtimeChatContainer({
    Key? key,
    required this.loggedInUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.messages,
    required this.isTyping,
    required this.sendMessage,
    required this.sendTypingStatus,
  }) : super(key: key);

  @override
  _RealtimeChatContainerState createState() => _RealtimeChatContainerState();
}

class _RealtimeChatContainerState extends State<RealtimeChatContainer> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final message = {
      'type': 'message',
      'from_user': widget.loggedInUserId,
      'to_user': widget.otherUserId,
      'message': messageText,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Send to database
    final url = Uri.parse(ApiConfig.sendMessage);
    try {
      final response = await http.post(url, body: {
        'from_user': widget.loggedInUserId.toString(),
        'to_user': widget.otherUserId.toString(),
        'message': messageText,
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Proceed to send via WebSocket
          try {
            widget.sendMessage(message);
            _messageController.clear();
          } catch (e) {
            print('WebSocket send error: $e');
          }
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _sendTypingStatus(bool isTyping) {
    final typingData = {
      'type': 'typing',
      'from_user': widget.loggedInUserId,
      'to_user': widget.otherUserId,
      'isTyping': isTyping,
    };
    try {
      widget.sendTypingStatus(typingData);
    } catch (e) {
      print('WebSocket send typing error: $e');
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['from_user'] == widget.loggedInUserId;
    return GestureDetector(
      onTap: () {
        print("Message tapped: \${message['message']}");
        // You can add more interaction here, e.g., show options or copy text
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: 250),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.green[400] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message['message'],
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
              SizedBox(height: 4),
              Text(
                message['timestamp'],
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  final message = widget.messages[widget.messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            if (widget.isTyping)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "\${widget.otherUserName} is typing...",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        widget.sendTypingStatus({
                          'type': 'typing', 
                          'from_user': widget.loggedInUserId,
                          'to_user': widget.otherUserId,
                          'isTyping': text.isNotEmpty,
                        });
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
