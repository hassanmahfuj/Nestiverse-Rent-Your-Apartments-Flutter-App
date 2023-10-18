import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

Future<Map<String, dynamic>> getUserProfile() async {
  DocumentSnapshot<Map<String, dynamic>> doc =
      await db.collection("users").doc(auth.currentUser!.uid).get();
  return doc.data()!;
}

Future<void> setUserMode(String mode) async {
  await db
      .collection("users")
      .doc(auth.currentUser!.uid)
      .update({"mode": mode});
}
