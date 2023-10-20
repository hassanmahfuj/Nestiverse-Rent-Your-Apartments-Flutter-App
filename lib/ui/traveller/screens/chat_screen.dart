import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/util.dart';

import '../../../service/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _conMessage = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200)).then((_) {
      if (_controller.hasClients) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
  }

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
                    controller: _controller,
                    padding: const EdgeInsets.all(0),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      bool self = snapshot.data!.docs[index]["sender"] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      return Align(
                        alignment:
                            self ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width / (10 / 8),
                          ),
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: self ? Colors.pinkAccent : Colors.grey,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                snapshot.data!.docs[index]["message"],
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatDate(snapshot
                                    .data!.docs[index]["timestamp"]
                                    .toDate()),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          "When ypu contact a Host or send a reservation request, you'll see your messages here.",
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _conMessage,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(_loading ? Icons.sync : Icons.send),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                          });
                          await forceSendMessage(
                              widget.conversationId, _conMessage.text);
                          _conMessage.clear();
                          setState(() {
                            _loading = false;
                          });
                          _scrollDown();
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
