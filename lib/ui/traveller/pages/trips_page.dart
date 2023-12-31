import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nestiverse/ui/traveller/screens/trip_details_screen.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String _getAvailableDateRangeString(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    DateTime s = doc["reserveStartDate"].toDate();
    DateTime e = doc["reserveEndDate"].toDate();
    return "${DateFormat("MMM d", "en_US").format(s)} - ${DateFormat("MMM d", "en_US").format(e)}";
  }

  String _getStatus(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    String s = doc["status"];
    DateTime e = doc["reserveEndDate"].toDate();
    if (s == "Accepted" && e.isBefore(DateTime.now())) {
      s = "Completed";
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AppBar(
            title: const Text(
              "Trips",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("bookings")
                  .where("guestUid",
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Icon(
                          Icons.leave_bags_at_home_outlined,
                          size: 40,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                        child: Text(
                          "Not traveled yet!",
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

                return ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    String status = _getStatus(snapshot.data!.docs[index]);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailsPage(
                                tripId: snapshot.data!.docs[index].id),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                snapshot.data!.docs[index]["listingPhoto"]),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.zero,
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                    topRight: Radius.zero),
                              ),
                              height: 70,
                              width: double.infinity,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 6),
                                title: Text(
                                  snapshot.data!.docs[index]["listingTitle"]
                                      .toString()
                                      .substring(0, 23),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                subtitle: Text(
                                  _getAvailableDateRangeString(
                                      snapshot.data!.docs[index]),
                                  style: const TextStyle(fontSize: 15),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        color: status == "Pending"
                                            ? Colors.orange
                                            : status == "Canceled"
                                                ? Colors.red
                                                : status == "Accepted"
                                                    ? Colors.green
                                                    : Colors.blue),
                                    Text(
                                      status,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
