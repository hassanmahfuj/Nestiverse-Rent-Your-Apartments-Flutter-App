import 'package:flutter/material.dart';

class DestinationViewScreen extends StatefulWidget {
  final Map<String, dynamic> destination;

  const DestinationViewScreen({super.key, required this.destination});

  static const route = "/traveller/destination";

  @override
  State<DestinationViewScreen> createState() => _DestinationViewScreenState();
}

class _DestinationViewScreenState extends State<DestinationViewScreen> {
  final Map<String, dynamic> _user = {
    "firstName": "Hassan",
    "lastName": "Mahfuj",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: <Widget>[
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(widget.destination["photos"][0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 5,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.destination["title"],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text("★ New · ${widget.destination["locAddress"]}"),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Entire place hosted by ${_user["firstName"]} ${_user["lastName"]}",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.account_circle,
                        size: 60,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${widget.destination["guests"].toString()} guests · ${widget.destination["bedrooms"].toString()} bedrooms · ${widget.destination["beds"].toString()} beds · ${widget.destination["bathrooms"].toString()} baths",
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.destination["description"],
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    "What this place offers",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.destination["benefits"].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        leading: Icon(
                          IconData(
                              widget.destination["benefits"][index]["icon"],
                              fontFamily: 'MaterialIcons'),
                          size: 35,
                        ),
                        title: Text(
                          widget.destination["benefits"][index]["title"],
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    "Where you'll be",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // map
                  Text(
                    widget.destination["locAddress"],
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  ListTile(
                    onTap: () {},
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Availability",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text("Oct 22 - Oct 27"),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black12,
            ),
          ),
        ),
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("\$${widget.destination["price"]} night"),
                  const Text("Oct 22 - Oct 27"),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text("Reserve"),
            ),
          ],
        ),
      ),
    );
  }
}