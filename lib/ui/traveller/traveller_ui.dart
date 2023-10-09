import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/traveller/pages/explore_page.dart';
import 'package:nestiverse/ui/traveller/pages/profile_page.dart';

class TravellerUi extends StatefulWidget {
  const TravellerUi({super.key});

  static const route = "/ui/traveller";

  @override
  State<TravellerUi> createState() => _TravellerUiState();
}

class _TravellerUiState extends State<TravellerUi> {
  final db = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    ExplorePage(),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: School',
      style: optionStyle,
    ),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.travel_explore_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.travel_explore_outlined,
              color: Colors.red,
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_outline_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.favorite_outline_outlined,
              color: Colors.red,
            ),
            label: 'Wishlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.luggage_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.luggage_outlined,
              color: Colors.red,
            ),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.chat_outlined,
              color: Colors.red,
            ),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.account_circle_outlined,
              color: Colors.red,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
