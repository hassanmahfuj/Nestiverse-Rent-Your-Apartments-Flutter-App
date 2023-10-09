import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/auth.dart';
import 'package:nestiverse/firebase_options.dart';
import 'package:nestiverse/gate.dart';
import 'package:nestiverse/ui/host/host_ui.dart';
import 'package:nestiverse/ui/host/pages/listing_page.dart';
import 'package:nestiverse/ui/host/pages/listings_page.dart';
import 'package:nestiverse/ui/traveller/traveller_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestiverse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
          fontFamily: 'AirbnbCereal'),
      initialRoute: Gate.route,
      routes: {
        Gate.route: (context) => const Gate(),
        Auth.route: (context) => const Auth(),
        TravellerUi.route: (context) => const TravellerUi(),
        HostUi.route: (context) => const HostUi(),
        ListingsPage.route: (context) => const ListingsPage(),
        ListingPage.route: (context) => const ListingPage(),
      },
    );
  }
}
