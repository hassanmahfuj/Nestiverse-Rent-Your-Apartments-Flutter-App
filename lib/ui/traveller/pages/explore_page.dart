import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nestiverse/ui/traveller/screens/destination_view_screen.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, dynamic>> _destinations = [];
  final List<String> _destinationsId = [];

  @override
  void initState() {
    super.initState();
    getDestinations();
  }

  void getDestinations() async {
    FirebaseFirestore.instance.collection("listings").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          _destinationsId.add(docSnapshot.id);
          _destinations.add(docSnapshot.data());
        }
        setState(() {});
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );
  }

  String _getAvailableDateRangeString(Map<String, dynamic> doc) {
    String out = "Not available";
    if (doc.containsKey("availableStartDate") &&
        doc.containsKey("availableEndDate")) {
      DateTime s = doc["availableStartDate"].toDate();
      DateTime e = doc["availableEndDate"].toDate();
      out =
          "${DateFormat("MMM d", "en_US").format(s)} - ${DateFormat("MMM d", "en_US").format(e)}";
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextField(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        hintText:
                            'Where to? \nAnywhere • Any week • Add guests',
                        hintMaxLines: 2,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
              itemCount: _destinations.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DestinationViewScreen(
                            destinationId: _destinationsId[index],
                            destination: _destinations[index]),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: <Widget>[
                          Container(
                            height: 380,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image: NetworkImage(
                                      _destinations[index]["photos"][0]),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const Positioned(
                            top: 20,
                            right: 20,
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 30,
                              shadows: [
                                BoxShadow(
                                  color: Colors.grey,
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _destinations[index]["title"],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "4.87",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${_destinations[index]["title"]} kilometers',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _getAvailableDateRangeString(_destinations[index]),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(
                            '\$${_destinations[index]["price"]}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            ' night',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
