import 'package:flutter/material.dart';

import '../../../service/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _conMessage = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getConversationMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data!.docs[index]["senderName"]),
                        subtitle: Text(snapshot.data!.docs[index]["message"]),
                      );
                    },
                  );
                } else {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 40,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        child: Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: Text(
                            textAlign: TextAlign.center,
                            "When ypu contact a Host or send a reservation request, you'll see your messages here."),
                      )
                    ],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _conMessage,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    await forceSendMessage(
                        widget.conversationId, _conMessage.text);
                    _conMessage.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}