import 'package:flutter/material.dart';
import 'package:nestiverse/service/chat_service.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AppBar(
            title: const Text(
              "Inbox",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  forceSendMessage("qnKAJyNFXuQNXCnvdrnuHd0BUKk1-mYvhREeRotPJ4Pce4WTxEhNZPji2", "hello");
                },
                icon: const Icon(Icons.account_circle),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: getConversationsForUser(),
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
                        title: Text(snapshot.data!.docs[index]["lastMessage"]),
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
                          "No new messages",
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
        ],
      ),
    );
  }
}
