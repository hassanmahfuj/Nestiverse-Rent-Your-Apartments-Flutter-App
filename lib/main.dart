import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'gate.dart';
import 'ui/auth.dart';
import 'ui/host/host_ui.dart';
import 'ui/host/screens/listing_screen.dart';
import 'ui/host/screens/listings_screen.dart';
import 'ui/traveller/traveller_ui.dart';

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
        fontFamily: 'AirbnbCereal',
      ),
      initialRoute: Gate.route,
      routes: {
        Gate.route: (context) => const Gate(),
        Auth.route: (context) => const Auth(),
        TravellerUi.route: (context) => const TravellerUi(),
        HostUi.route: (context) => const HostUi(),
        ListingsScreen.route: (context) => const ListingsScreen(),
        ListingScreen.route: (context) => const ListingScreen(),
      },
    );
  }
}
