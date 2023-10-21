import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDetailsPage extends StatefulWidget {
  final String tripId;

  const TripDetailsPage({super.key, required this.tripId});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final db = FirebaseFirestore.instance;

  _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    db.collection("bookings").doc(widget.tripId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // if reserve start date is greeter than today's date is
                    // meant to be expired request
                    DateTime s = snapshot.data!["reserveStartDate"].toDate();
                    bool isExpired = s.isAfter(DateTime.now());

                    return Column(
                      children: [
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image:
                                  NetworkImage(snapshot.data!["listingPhoto"]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          snapshot.data!["listingTitle"],
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          snapshot.data!["listingAddress"],
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_month_outlined,
                            size: 40,
                          ),
                          title: Text(
                            "${DateFormat("MMM d", "en_US").format(snapshot.data!["reserveStartDate"].toDate())} - ${DateFormat("MMM d", "en_US").format(snapshot.data!["reserveEndDate"].toDate())}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: const Text("Reservation date range"),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.face,
                            size: 40,
                          ),
                          title: Text(
                            "Adults ${snapshot.data!["guestAdult"]}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: const Text("Guests"),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.child_care,
                            size: 40,
                          ),
                          title: Text(
                            "Children ${snapshot.data!["guestChildren"]}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: const Text("Guests"),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.pets,
                            size: 40,
                          ),
                          title: Text(
                            "Pets ${snapshot.data!["guestPets"]}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: const Text("Guests"),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                            child: Text(
                              "৳",
                              style: TextStyle(
                                fontSize: 45,
                              ),
                            ),
                          ),
                          title: Text(
                            "Reserve for ${snapshot.data!["reservedDays"]} days",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          trailing: Text(
                            "৳${snapshot.data!["subTotal"].toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.pending_outlined,
                            size: 40,
                          ),
                          title: const Text(
                            "Status",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          trailing: Text(
                            snapshot.data!["status"],
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
