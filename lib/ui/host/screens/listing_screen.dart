import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ListingScreen extends StatefulWidget {
  final String? listingId;

  const ListingScreen({super.key, this.listingId});

  static const route = "/host/listing";

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final db = FirebaseFirestore.instance;

  int _index = 0;
  final int _totalSteps = 7; // +1

  @override
  void initState() {
    super.initState();

    if (widget.listingId != null) {
      getListing();
    }
  }

  void getListing() async {
    FirebaseFirestore.instance
        .collection("listings")
        .doc(widget.listingId)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;

        setCategory(data["category"]);

        _conAddress.text = data["locAddress"];
        _locationLat = data["locLatitude"];
        _locationLng = data["locLongitude"];

        _guests = data["guests"];
        _bedrooms = data["bedrooms"];
        _beds = data["beds"];
        _bathrooms = data["bathrooms"];

        selectBenefits(data["benefits"]);

        for (dynamic photo in data["photos"]) {
          _photos.add(photo);
        }

        _conTitle.text = data["title"];
        _conDescription.text = data["description"];
        _conPrice.text = data["price"];

        setState(() {});
      },
      onError: (e) => debugPrint("Error completing: $e"),
    );
  }

  void setCategory(String title) {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i]["title"] == title) {
        _selectedCategory = i;
        break;
      }
    }
  }

  void selectBenefits(dynamic selectedBenefits) {
    for (dynamic element in selectedBenefits) {
      for (int i = 0; i < _benefits.length; i++) {
        if (element["title"] == _benefits[i]["title"]) {
          _benefits[i]["active"] = true;
          break;
        }
      }
    }
  }

  // Category
  int _selectedCategory = 0;
  final List<dynamic> _categories = [
    {"icon": Icons.house.codePoint, "title": "House"},
    {"icon": Icons.apartment.codePoint, "title": "Apartment"},
    {"icon": Icons.house.codePoint, "title": "Barn"},
    {"icon": Icons.directions_boat.codePoint, "title": "Boat"},
  ];

  // Location
  final TextEditingController _conAddress = TextEditingController();
  String _locationLat = "";
  String _locationLng = "";

  // Basics
  int _guests = 4;
  int _bedrooms = 1;
  int _beds = 1;
  int _bathrooms = 1;

  // Benefits
  final List<dynamic> _benefits = [
    {"icon": Icons.wifi.codePoint, "title": "Wifi", "active": false},
    {"icon": Icons.tv.codePoint, "title": "TV", "active": false},
    {"icon": Icons.kitchen.codePoint, "title": "Kitchen", "active": false},
    {"icon": Icons.air.codePoint, "title": "AC", "active": false},
    {"icon": Icons.pool.codePoint, "title": "Pool", "active": false},
  ];

  // Photos
  final List<String> _photos = [];

  bool _isLoading = false;

  void uploadPhoto(ImageSource source) async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference refImageToUpload = FirebaseStorage.instance
        .ref()
        .child('images')
        .child("$uniqueFileName.${file.name.split(".")[1]}");

    setState(() {
      _isLoading = true;
    });
    try {
      await refImageToUpload.putFile(File(file.path));
      String imageUrl = await refImageToUpload.getDownloadURL();
      setState(() {
        _photos.add(imageUrl);
      });
    } catch (error) {
      debugPrint(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Title
  final TextEditingController _conTitle = TextEditingController();

  // Description
  final TextEditingController _conDescription = TextEditingController();

  // Price
  final TextEditingController _conPrice = TextEditingController();

  void _saveToDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final List<dynamic> selectedBenefits = [];
    for (dynamic element in _benefits) {
      if (element["active"] == true) {
        selectedBenefits.add(element);
      }
    }

    final db = FirebaseFirestore.instance;
    final listing = <String, dynamic>{
      "hostUid": FirebaseAuth.instance.currentUser!.uid,
      "category": _categories[_selectedCategory]["title"],
      "locAddress": _conAddress.text,
      "locLatitude": _locationLat,
      "locLongitude": _locationLng,
      "guests": _guests,
      "bedrooms": _bedrooms,
      "beds": _beds,
      "bathrooms": _bathrooms,
      "benefits": selectedBenefits,
      "photos": _photos,
      "title": _conTitle.text,
      "description": _conDescription.text,
      "price": _conPrice.text,
      "status": "Reserved",
    };

    if (widget.listingId == null) {
      await db.collection("listings").add(listing);
    } else {
      await db.collection("listings").doc(widget.listingId).update(listing);
    }
    _close();
  }

  void _close() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Manage your listing",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stepper(
                currentStep: _index,
                onStepCancel: () {
                  if (_index > 0) {
                    setState(() {
                      _index -= 1;
                    });
                  }
                },
                onStepContinue: () {
                  if (_index < _totalSteps) {
                    setState(() {
                      _index += 1;
                    });
                  } else {
                    // Save to database
                    // print("save");
                    _saveToDatabase();
                  }
                },
                onStepTapped: (int index) {
                  setState(() {
                    _index = index;
                  });
                },
                controlsBuilder: (context, details) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: _isLoading,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                Text(_index == _totalSteps ? 'Save' : 'Next'),
                          ),
                          const SizedBox(width: 12),
                          Visibility(
                            visible: _index != 0,
                            child: TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Back'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                steps: <Step>[
                  Step(
                    isActive: _index >= 0,
                    title: const Text(
                      'Which of these best describes your place',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 10 / 7,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = index;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedCategory == index
                                      ? Colors.black
                                      : Colors.grey,
                                  width: _selectedCategory == index ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconData(_categories[index]["icon"],
                                        fontFamily: 'MaterialIcons'),
                                    size: 30,
                                  ),
                                  Text(
                                    _categories[index]["title"],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 1,
                    title: const Text(
                      "Where's your place located?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: TextField(
                        controller: _conAddress,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 2,
                    title: const Text(
                      "Share some basics about your place",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: const Text(
                            "Guests",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_guests == 1) return;
                                  setState(() {
                                    _guests--;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _guests.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _guests++;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: const Text(
                            "Bedrooms",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_bedrooms == 1) return;
                                  setState(() {
                                    _bedrooms--;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _bedrooms.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _bedrooms++;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: const Text(
                            "Beds",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_beds == 1) return;
                                  setState(() {
                                    _beds--;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _beds.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _beds++;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: const Text(
                            "Bathrooms",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_bathrooms == 1) return;
                                  setState(() {
                                    _bathrooms--;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _bathrooms.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _bathrooms++;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    isActive: _index >= 3,
                    title: const Text(
                      'Tell guests what your place has to offer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 10 / 7,
                        ),
                        itemCount: _benefits.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _benefits[index]["active"] =
                                    !_benefits[index]["active"];
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _benefits[index]["active"]
                                      ? Colors.black
                                      : Colors.grey,
                                  width: _benefits[index]["active"] ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconData(_benefits[index]["icon"],
                                        fontFamily: 'MaterialIcons'),
                                    size: 30,
                                  ),
                                  Text(
                                    _benefits[index]["title"],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 4,
                    title: const Text(
                      'Add some photos of your apartment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              uploadPhoto(ImageSource.gallery);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 30,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Add photos",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              uploadPhoto(ImageSource.camera);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 30,
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    "Take new photos",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _photos.length,
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _photos[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 5,
                    title: const Text(
                      "Now, let's give your apartment a title",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: TextField(
                        controller: _conTitle,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 6,
                    title: const Text(
                      "Create your description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: TextField(
                        controller: _conDescription,
                        minLines: 5,
                        maxLines: 20,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Step(
                    isActive: _index >= 7,
                    title: const Text(
                      "Now, set your price",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: TextField(
                      controller: _conPrice,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: const InputDecoration(
                        prefix: Text(
                          "৳",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
