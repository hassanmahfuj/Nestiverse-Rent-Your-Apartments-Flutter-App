import 'package:flutter/material.dart';
import 'package:nestiverse/ui/traveller/traveller_ui.dart';

class ReserveSuccessScreen extends StatefulWidget {
  const ReserveSuccessScreen({super.key});

  @override
  State<ReserveSuccessScreen> createState() => _ReserveSuccessScreenState();
}

class _ReserveSuccessScreenState extends State<ReserveSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 50),
            const Text(
              "Your Reservation\nHas Been Placed",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your reservation has been placed and is\non its way to being accepted by the host",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TravellerUi(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Back To Home",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
