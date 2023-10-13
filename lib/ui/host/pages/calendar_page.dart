import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final db = FirebaseFirestore.instance;

  String _getAvailableDateRangeString(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    String out = "Not available";
    if (data.containsKey("availableStartDate") &&
        doc.data().containsKey("availableEndDate")) {
      DateTime s = data["availableStartDate"].toDate();
      DateTime e = data["availableEndDate"].toDate();
      out =
          "${DateFormat("MMM d", "en_US").format(s)} - ${DateFormat("MMM d", "en_US").format(e)}";
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Calendar",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Manage your listings availability",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: db.collection("listings").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: ListTile(
                            onTap: () async {
                              DateTime lastCheckoutDate = DateTime.now();
                              DateTime availableStartDate = DateTime.now();
                              DateTime availableEndDate = DateTime.now();

                              try {
                                availableStartDate = snapshot.data!.docs[index]
                                    ["availableStartDate"].toDate();
                                availableEndDate = snapshot.data!.docs[index]
                                    ["availableEndDate"].toDate();
                              } catch (e) {}

                              try {
                                lastCheckoutDate = snapshot.data!.docs[index]
                                    ["lastCheckoutDate"].toDate();
                                if(lastCheckoutDate.isAfter(availableStartDate)) {
                                  availableStartDate = lastCheckoutDate;
                                  availableEndDate = lastCheckoutDate;
                                }
                              } catch (e) {}

                              final DateTimeRange? result =
                                  await showDateRangePicker(
                                context: context,
                                initialDateRange: DateTimeRange(
                                  start: availableStartDate,
                                  end: availableEndDate,
                                ),
                                firstDate: lastCheckoutDate,
                                lastDate: lastCheckoutDate.add(
                                  const Duration(days: 30),
                                ),
                              );

                              if (result != null) {
                                db
                                    .collection("listings")
                                    .doc(snapshot.data!.docs[index].id)
                                    .update({
                                  "availableStartDate": result.start,
                                  "availableEndDate": result.end,
                                  "status": "Available",
                                });
                              }
                            },
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 20,
                            ),
                            tileColor: Colors.white,
                            leading: Image.network(
                              snapshot.data!.docs[index]["photos"][0],
                              width: 70,
                            ),
                            title: Text(
                              snapshot.data!.docs[index]["title"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              _getAvailableDateRangeString(
                                  snapshot.data!.docs[index]),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.calendar_month_outlined,
                              size: 50,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
