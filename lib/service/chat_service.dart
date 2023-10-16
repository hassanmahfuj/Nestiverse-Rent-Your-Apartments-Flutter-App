import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String compositeConversationId(String participantId) {
  List<String> participantUserIDs = [];
  participantUserIDs.add(participantId);

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserId = currentUser!.uid;
  participantUserIDs.add(currentUserId);

  participantUserIDs.sort();
  return participantUserIDs.join('-');
}

Future<String> getUsername(String userId) async {
  final data = await FirebaseFirestore.instance.collection("users").doc(userId).get();
  return data["firstName"] + " " + data["lastName"];
}

Future<void> forceSendMessage(String conversationID, String message) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserId = currentUser!.uid;
  final String currentUserName = await getUsername(currentUserId);

  final DocumentSnapshot existingConversationSnapshot =
      await firestore.collection('conversations').doc(conversationID).get();

  if (!existingConversationSnapshot.exists) {
    final DocumentReference conversationRef =
        firestore.collection('conversations').doc(conversationID);

    final List<String> conversationParticipants = conversationID.split("-");
    final List<String> conversationParticipantsName = [];
    for(String participant in conversationParticipants) {
      String name = await getUsername(participant);
      conversationParticipantsName.add(name);
    }

    await conversationRef.set({
      'participants': conversationParticipants,
      'participantsName': conversationParticipantsName,
      'lastMessage': "",
      'lastSenderName': "",
    });
  }

  final CollectionReference messagesRef = firestore
      .collection('conversations')
      .doc(conversationID)
      .collection('messages');

  await messagesRef.add({
    'sender': currentUserId,
    'senderName': currentUserName,
    'message': message,
    'timestamp': FieldValue.serverTimestamp(),
  });

  await firestore.collection('conversations').doc(conversationID).update({
    'lastMessage': message,
    'lastSenderName': currentUserName,
    'timestamp': FieldValue.serverTimestamp(),
  });
  print("done");
}

// Future<void> startConversation(List<String> participantUserIDs) async {
//   try {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     final String currentUserId = currentUser!.uid;
//
//     participantUserIDs.sort();
//     final String conversationID = participantUserIDs.join('-');
//
//     final DocumentSnapshot existingConversationSnapshot =
//         await firestore.collection('conversations').doc(conversationID).get();
//
//     if (existingConversationSnapshot.exists) {
//       // An existing conversation was found; you can handle this case as needed
//       // You might navigate to the chat screen for the existing conversation.
//     } else {
//       // Create a new conversation document
//       final DocumentReference conversationRef =
//           firestore.collection('conversations').doc(conversationID);
//
//       // Add the current user and participants to the conversation
//       final List<String> conversationParticipants = [
//         currentUserId,
//         ...participantUserIDs
//       ];
//
//       await conversationRef.set({
//         'participants': conversationParticipants,
//         'lastMessage': '', // You can initialize it with an empty message
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       // You can navigate to the chat screen with the newly created conversation here
//     }
//   } catch (e) {
//     print('Error starting a conversation: $e');
//   }
// }

Stream<QuerySnapshot<Map<String, dynamic>>> getConversationsForUser() {
  // Get the current user's ID (you should have authenticated the user already)
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserId = currentUser!.uid;

  // Get a reference to the Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the Firestore database to get conversations for the user
  return firestore
      .collection('conversations')
      .where('participants', arrayContains: currentUserId)
      .snapshots();
}

// Future<void> sendMessage(String conversationID, String content) async {
//   try {
//     // Get the current user's ID (you should have authenticated the user already)
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     final String currentUserId = currentUser!.uid;
//
//     // Get a reference to the Firestore instance
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//     // Create a new message document in the conversation's subcollection
//     final CollectionReference messagesRef = firestore
//         .collection('conversations')
//         .doc(conversationID)
//         .collection('messages');
//
//     await messagesRef.add({
//       'sender': currentUserId,
//       'content': content,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//
//     // Update the lastMessage and timestamp in the conversation document
//     await firestore.collection('conversations').doc(conversationID).update({
//       'lastMessage': content,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   } catch (e) {
//     print('Error sending a message: $e');
//   }
// }

Future<List<QueryDocumentSnapshot>> getConversationMessages(
    String conversationID) async {
  try {
    // Get a reference to the Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query the Firestore database to get messages for the specified conversation
    final QuerySnapshot messagesSnapshot = await firestore
        .collection('conversations')
        .doc(conversationID)
        .collection('messages')
        .orderBy('timestamp',
            descending: false) // Adjust the sorting order as needed
        .get();

    return messagesSnapshot.docs;
  } catch (e) {
    print('Error fetching conversation messages: $e');
    return [];
  }
}
