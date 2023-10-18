import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nestiverse/service/chat_service.dart';
import 'package:nestiverse/ui/traveller/screens/chat_screen.dart';
import 'package:nestiverse/ui/traveller/screens/full_photo_view.dart';
import 'package:nestiverse/ui/traveller/screens/reserve_screen.dart';

class DestinationViewScreen extends StatefulWidget {
  final String destinationId;
  final Map<String, dynamic> destination;

  const DestinationViewScreen(
      {super.key, required this.destinationId, required this.destination});

  static const route = "/traveller/destination";

  @override
  State<DestinationViewScreen> createState() => _DestinationViewScreenState();
}

class _DestinationViewScreenState extends State<DestinationViewScreen> {
  String _username = "";
  String _availableDates = "Not available";

  @override
  void initState() {
    super.initState();
    retrieveUsername();
  }

  void retrieveUsername() async {
    _username = await getUsername(widget.destination["hostUid"]);
    setState(() {});
  }

  String _getAvailableDateRangeString(Map<String, dynamic> doc) {
    if (doc.containsKey("availableStartDate") &&
        doc.containsKey("availableEndDate")) {
      DateTime s = doc["availableStartDate"].toDate();
      DateTime e = doc["availableEndDate"].toDate();
      _availableDates =
          "${DateFormat("MMM d", "en_US").format(s)} - ${DateFormat("MMM d", "en_US").format(e)}";
    }
    return _availableDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: <Widget>[
                // Container(
                //   height: 300,
                //   decoration: BoxDecoration(
                //     // borderRadius: BorderRadius.circular(15),
                //     image: DecorationImage(
                //       image: NetworkImage(widget.destination["photos"][0]),
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    autoPlay: true,
                  ),
                  items: widget.destination["photos"].map<Widget>((i) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPhotoView(photoUrl: i),
                          ),
                        );
                      },
                      child: Image.network(
                        i,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
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
                          "Entire place hosted by $_username",
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: compositeConversationId(
                                widget.destination["hostUid"]),
                          ),
                        ),
                      );
                    },
                    child: const Text("Send message"),
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
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Availability",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle:
                        Text(_getAvailableDateRangeString(widget.destination)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  const ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Safety & property",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "Carbon monoxide not reported\nSmoke alarm not reported",
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  const ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: Icon(Icons.flag),
                    title: Text(
                      "Report this listing",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 4,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
          border: const Border(
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
                  Text(
                    "\$${widget.destination["price"]} night",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(_getAvailableDateRangeString(widget.destination)),
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
              onPressed: _availableDates == "Not available"
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReserveScreen(listingId: widget.destinationId),
                        ),
                      );
                    },
              child: const Text("Reserve"),
            ),
          ],
        ),
      ),
    );
  }
}
