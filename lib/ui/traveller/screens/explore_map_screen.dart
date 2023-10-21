import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'destination_view_screen.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialLocation = CameraPosition(
    target: LatLng(23.7781543, 90.3769411),
    zoom: 15,
  );

  final Set<Marker> _marks = {};

  @override
  void initState() {
    super.initState();
    _getMarkers();
  }

  void _getMarkers() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection("listings")
        .where("hostUid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    int i = 0;
    for (DocumentSnapshot<Map<String, dynamic>> docSnapshot
        in querySnapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data()!;
      _marks.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(double.parse(data["locLatitude"]),
              double.parse(data["locLongitude"])),
          infoWindow: InfoWindow(
            title: "৳${data["price"]}",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DestinationViewScreen(
                    destinationId: docSnapshot.id,
                    destination: data,
                  ),
                ),
              );
            },
          ),
        ),
      );
      i++;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: _initialLocation,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _marks,
    );
  }
}
