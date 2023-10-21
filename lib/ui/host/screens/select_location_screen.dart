import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialLocation = CameraPosition(
    target: LatLng(23.7781543, 90.3769411),
    zoom: 15,
  );

  LatLng _position = const LatLng(23.7777076,90.3776921);

  bool _isLoading = false;
  String _address = "IDB Bhaban, E/8-A, Dhaka 1207";
  String _latitude = "23.7777076";
  String _longitude = "90.3776921";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _initialLocation,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                markerId: const MarkerId('Selected'),
                position: _position,
              ),
            },
            onTap: (LatLng location) async {
              setState(() {
                _isLoading = true;
                _position = location;
                _latitude = location.latitude.toString();
                _longitude = location.longitude.toString();
              });
              List<Placemark> placeMarks = await placemarkFromCoordinates(
                  location.latitude, location.longitude);
              setState(() {
                _isLoading = false;

                String street = placeMarks[0].street ?? "";
                String thoroughfare = placeMarks[0].thoroughfare ?? "";
                String subLocality = placeMarks[0].subLocality ?? "";
                String locality = placeMarks[0].locality ?? "";
                String country = placeMarks[0].country ?? "";

                _address =
                    "$street $thoroughfare $subLocality $locality $country";
              });
            },
          ),
          Positioned(
            right: 20,
            bottom: 135,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.pink,
              ),
              onPressed: () {
                List<String> data = [_address, _latitude, _longitude];
                Navigator.pop(context, data);
              },
              child: const Text("Select this address"),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _address,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: _isLoading,
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
