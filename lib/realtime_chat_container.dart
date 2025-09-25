import 'package:flutter/material.dart';

class RealtimeChatContainer extends StatefulWidget {
  final List<Map<String, dynamic>> messages;      // full message list
  final int loggedInUserId;                       // my id
  final int otherUserId;                           // partner id
  final bool isTyping;
  final Future<void> Function(Map<String, dynamic>) sendMessage;
  final TextEditingController textController;
  final ScrollController scrollController;

  const RealtimeChatContainer({
    super.key,
    required this.messages,
    required this.loggedInUserId,
    required this.otherUserId,
    required this.isTyping,
    required this.sendMessage,
    required this.textController,
    required this.scrollController,
  });

  @override
  State<RealtimeChatContainer> createState() => _RealtimeChatContainerState();
}

class _RealtimeChatContainerState extends State<RealtimeChatContainer> {
  Future<void> _send() async {
    final text = widget.textController.text.trim();
    if (text.isEmpty) return;

    final newMsg = {
      'type': 'message',
      'from_user': widget.loggedInUserId,
      'to_user': widget.otherUserId,
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await widget.sendMessage(newMsg);
    widget.textController.clear();

    // scroll to bottom after a tiny delay
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.scrollController.jumpTo(
        widget.scrollController.position.maxScrollExtent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final msg = widget.messages[index];
              final isMe = msg['from_user'] == widget.loggedInUserId;

              return Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 260),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.green[400] : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          isMe ? const Radius.circular(16) : Radius.zero,
                      bottomRight:
                          isMe ? Radius.zero : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['message'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (msg['timestamp'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            msg['timestamp'].toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (widget.isTyping)
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Typing...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),

        // Input field
        SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.textController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
