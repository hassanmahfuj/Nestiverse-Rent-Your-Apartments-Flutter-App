import 'package:flutter/material.dart';

class WishlistsPage extends StatefulWidget {
  const WishlistsPage({super.key});

  @override
  State<WishlistsPage> createState() => _WishlistsPageState();
}

class _WishlistsPageState extends State<WishlistsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AppBar(
            title: const Text(
              "Wishlists",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Text(
              "Create your first wishlist",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Text(
                "As you search, tap the heart icon to save your favorite places and Experiences to a list."),
          )
        ],
      ),
    );
  }
}
