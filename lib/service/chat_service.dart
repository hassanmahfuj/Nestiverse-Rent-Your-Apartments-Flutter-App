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
  final data =
      await FirebaseFirestore.instance.collection("users").doc(userId).get();
  return data["firstName"] + " " + data["lastName"];
}

int getRecipientIndex(List<dynamic> participants) {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String currentUserId = currentUser!.uid;
  for (int i = 0; i < participants.length; i++) {
    if (participants[i] != currentUserId) {
      return i;
    }
  }
  return 0;
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
    for (String participant in conversationParticipants) {
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
}

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

Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages(
    String conversationID) {
  // Get a reference to the Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Query the Firestore database to get messages for the specified conversation
  return firestore
      .collection('conversations')
      .doc(conversationID)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}
