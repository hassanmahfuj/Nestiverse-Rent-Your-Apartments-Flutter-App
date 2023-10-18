import 'package:flutter/material.dart';
import 'package:nestiverse/gate.dart';
import 'package:nestiverse/service/user_service.dart';
import 'package:nestiverse/ui/auth.dart';
import 'package:nestiverse/ui/host/screens/listing_screen.dart';
import 'package:nestiverse/ui/host/screens/listings_screen.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  void _switchToTravelling() async {
    await setUserMode("Traveler");
    _reload();
  }

  void _reload() {
    Navigator.pushReplacementNamed(context, Gate.route);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Menu",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Hosting",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.menu_book,
                size: 30,
              ),
              title: const Text(
                "Guidebooks",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, ListingsScreen.route);
              },
              leading: const Icon(
                Icons.home_work_outlined,
                size: 30,
              ),
              title: const Text(
                "Listings",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, ListingScreen.route);
              },
              leading: const Icon(
                Icons.add_home_work_outlined,
                size: 30,
              ),
              title: const Text(
                "Create a new listing",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              "Account",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.account_circle_outlined,
                size: 30,
              ),
              title: const Text(
                "Your profile",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.settings_outlined,
                size: 30,
              ),
              title: const Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              contentPadding: const EdgeInsets.all(0),
              trailing: const Icon(Icons.keyboard_arrow_right_outlined),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.pink,
                side: const BorderSide(color: Colors.pink),
                fixedSize: const Size(double.maxFinite, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _switchToTravelling(),
              child: const Text(
                "Switch to traveling",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 15),
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
                auth.signOut();
                Navigator.pushReplacementNamed(context, Auth.route);
              },
              child: const Text(
                "Log out",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
