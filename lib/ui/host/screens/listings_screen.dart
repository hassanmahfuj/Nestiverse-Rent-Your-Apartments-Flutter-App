import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/host/screens/listing_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  static const route = "/host/listings";

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Listings",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder(
                  stream: db
                      .collection("listings")
                      // .where("availability", isLessThan: DateTime(2023, 10, 10))
                      .snapshots(),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: ListTile(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              tileColor: Colors.white,
                              leading: Image.network(
                                snapshot.data!.docs[index]["photos"][0],
                                width: 70,
                              ),
                              title: Text(
                                snapshot.data!.docs[index]["title"],
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ListingScreen(
                                          listingId:
                                              snapshot.data!.docs[index].id),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
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
      ),
    );
  }
}
