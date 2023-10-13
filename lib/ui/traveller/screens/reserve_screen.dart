import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nestiverse/ui/traveller/screens/reserve_success_screen.dart';

class ReserveScreen extends StatefulWidget {
  final String listingId;

  const ReserveScreen({super.key, required this.listingId});

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  void _getDestination() {
    FirebaseFirestore.instance
        .collection("listings")
        .doc(widget.listingId)
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      _hostUid = data["hostUid"];
      _title = data["title"];
      _locAddress = data["locAddress"];
      _photo = data["photos"][0];

      _availableStartDate = data["availableStartDate"].toDate();
      _availableEndDate = data["availableEndDate"].toDate();
      _reserveStartDate = _availableStartDate;
      _reserveEndDate = _availableEndDate;

      _pricePerNight = double.parse(data["price"]);

      _calcPrices();
    });
  }

  @override
  void initState() {
    super.initState();
    _getDestination();
  }

  // host info
  String _hostUid = "";

  // basic
  String _title = "";
  String _locAddress = "";
  String _photo = "http://via.placeholder.com/640x360";

  // trip dates
  DateTime _availableStartDate = DateTime.now();
  DateTime _availableEndDate = DateTime.now();
  DateTime _reserveStartDate = DateTime.now();
  DateTime _reserveEndDate = DateTime.now();

  // guests
  int _adults = 1;
  int _children = 0;
  int _pets = 0;
  int _totalGuests = 1;

  void _calcTotalGuests() {
    setState(() {
      _totalGuests = _adults + _children + _pets;
    });
  }

  // calc prices
  double _pricePerNight = 0;
  int _reserveDays = 0;
  double _subTotal = 0;
  double _serviceFee = 0;
  double _taxes = 0;
  double _total = 0;

  // card fields
  final TextEditingController _conCardNumber = TextEditingController();
  final TextEditingController _conCardExpiration = TextEditingController();
  final TextEditingController _conCardCvv = TextEditingController();

  void _calcPrices() {
    Duration difference = _reserveEndDate.difference(_reserveStartDate);
    _reserveDays = difference.inDays + 1;

    _subTotal = _pricePerNight * _reserveDays;
    _serviceFee = _subTotal * 0.05;
    _taxes = _subTotal * 0.1;
    _total = _subTotal + _serviceFee + _taxes;

    setState(() {});
  }

  void _requestBooking() async {
    final db = FirebaseFirestore.instance;
    final bookData = <String, dynamic>{
      "hostUid": _hostUid,
      "guestUid": FirebaseAuth.instance.currentUser!.uid,
      "listingId": widget.listingId,
      "listingTitle": _title,
      "listingAddress": _locAddress,
      "listingPhoto": _photo,
      "reserveStartDate": _reserveStartDate,
      "reserveEndDate": _reserveEndDate,
      "guestAdult": _adults,
      "guestChildren": _children,
      "guestPets": _pets,
      "listingPrice": _pricePerNight,
      "reservedDays": _reserveDays,
      "subTotal": _subTotal,
      "serviceFee": _serviceFee,
      "taxes": _taxes,
      "total": _total,
      "cardNumber": _conCardNumber.text,
      "cardExpiration": _conCardExpiration.text,
      "cardCvv": _conCardCvv.text,
      "status": "Pending",
    };

    await db.collection("bookings").add(bookData);
    await db.collection("listings").doc(widget.listingId).update({
      "lastCheckoutDate": _reserveEndDate.add(
        const Duration(days: 1),
      ),
      "status": "Reserved",
    });

    _showReservationSuccessScreen();
  }

  void _showReservationSuccessScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ReserveSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request to book"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(_photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _locAddress,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your trip",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Dates",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "${DateFormat("MMM d", "en_US").format(_reserveStartDate)} - ${DateFormat("MMM d", "en_US").format(_reserveEndDate)}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final DateTimeRange? result = await showDateRangePicker(
                          context: context,
                          initialDateRange: DateTimeRange(
                            start: _reserveStartDate,
                            end: _reserveEndDate,
                          ),
                          firstDate: _availableStartDate,
                          lastDate: _availableEndDate,
                        );
                        if (result != null) {
                          _reserveStartDate = result.start;
                          _reserveEndDate = result.end;
                          setState(() {
                            _calcPrices();
                          });
                        }
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Guests",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "${_totalGuests.toString()} guests",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        showModalBottomSheet<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setModalState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _calcTotalGuests();
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.close),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Guests",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(width: 10),
                                  ListTile(
                                    // contentPadding: const EdgeInsets.all(0),
                                    title: const Text(
                                      "Adults",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_adults == 1) return;
                                            setModalState(() {
                                              _adults--;
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
                                            _adults.toString(),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setModalState(() {
                                              _adults++;
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
                                  const SizedBox(height: 10),
                                  ListTile(
                                    // contentPadding: const EdgeInsets.all(0),
                                    title: const Text(
                                      "Children",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_children == 0) return;
                                            setModalState(() {
                                              _children--;
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
                                            _children.toString(),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setModalState(() {
                                              _children++;
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
                                  const SizedBox(height: 10),
                                  ListTile(
                                    // contentPadding: const EdgeInsets.all(0),
                                    title: const Text(
                                      "Pets",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_pets == 0) return;
                                            setModalState(() {
                                              _pets--;
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
                                            _pets.toString(),
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setModalState(() {
                                              _pets++;
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
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () {
                                          _calcTotalGuests();

                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Save",
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                            });
                          },
                        );
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price details",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "৳${_pricePerNight.toStringAsFixed(2)} x $_reserveDays nights",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "৳${_subTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Nestiverse service fee",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "৳${_serviceFee.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Taxes",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "৳${_taxes.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Total",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "৳${_total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pay with",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _conCardNumber,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      labelText: "Card number",
                      suffixIcon: Icon(Icons.credit_card_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _conCardExpiration,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            labelText: "Expiration",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _conCardCvv,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            labelText: "CVV",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cancellation policy",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Cancel before Oc 15 for a partial refund. After that, this reservation is non-refundable.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ground rules",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "We ask every guest to remember a few simple things about what makes a great guest.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "· Follow the house rules",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "· Treat your Host's home like your own",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: const Row(
                children: [
                  Icon(
                    Icons.event_repeat_outlined,
                    color: Colors.pink,
                    size: 40,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "Your reservation won't be confirmed until the Host accepts your request (within 24 hours). You won't be charged until then.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.black12,
              thickness: 10,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "By selecting the button bellow, I agree to the Host's House Rules, Ground rules for guests, Nestiverse Rebooking and Refund Policy, and that Nestiverse can charge my payment method if I'm responsible for the damage. I agree to pay the total amount shown if the Host accepts my booking request.",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(double.maxFinite, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      _requestBooking();
                    },
                    child: const Text(
                      "Request to book",
                      style: TextStyle(
                        fontSize: 18,
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
