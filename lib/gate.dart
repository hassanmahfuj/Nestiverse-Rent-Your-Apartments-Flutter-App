import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/auth.dart';
import 'package:nestiverse/ui/host/host_ui.dart';
import 'package:nestiverse/ui/traveller/traveller_ui.dart';

class Gate extends StatefulWidget {
  const Gate({super.key});

  static const route = "/";

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  @override
  void initState() {
    checkAuth();
    super.initState();
  }

  void checkAuth() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (FirebaseAuth.instance.currentUser == null) {
          Navigator.pushReplacementNamed(context, Auth.route);
        } else {
          checkMode();
        }
      },
    );
  }

  void checkMode() {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("users").doc(auth.currentUser!.uid);
    docRef.get().then(
      (DocumentSnapshot doc) {
        String mode = doc["mode"];
        if (mode == "Traveller") {
          Navigator.pushReplacementNamed(context, TravellerUi.route);
        } else {
          Navigator.pushReplacementNamed(context, HostUi.route);
        }
      },
      onError: (e) => debugPrint("Error getting document: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Loading..."),
            ),
          ],
        ),
      ),
    );
  }
}
