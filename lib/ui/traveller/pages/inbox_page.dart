import 'package:flutter/material.dart';
import 'package:nestiverse/service/chat_service.dart';
import 'package:nestiverse/ui/traveller/screens/chat_screen.dart';
import 'package:nestiverse/util.dart';

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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: snapshot.data!.docs[index].id,
                              ),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.account_circle,
                          size: 45,
                        ),
                        title: Text(
                          snapshot.data!.docs[index]["participantsName"][
                              getRecipientIndex(
                                  snapshot.data!.docs[index]["participants"])],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          snapshot.data!.docs[index]["lastMessage"],
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        trailing: Text(
                          formatDate(snapshot.data!.docs[index]["timestamp"].toDate()),
                          style: const TextStyle(
                            color: Colors.grey,
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
                            "When you contact a Host or send a reservation request, you'll see your messages here."),
                      ),
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
