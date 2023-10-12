import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/host/pages/calendar_page.dart';
import 'package:nestiverse/ui/host/pages/menu_page.dart';
import 'package:nestiverse/ui/host/pages/today_page.dart';

class HostUi extends StatefulWidget {
  const HostUi({super.key});

  static const route = "/ui/host";

  @override
  State<HostUi> createState() => _HostUiState();
}

class _HostUiState extends State<HostUi> {
  final db = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    TodayPage(),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    CalendarPage(),
    Text(
      'Index 3: School',
      style: optionStyle,
    ),
    MenuPage()
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
              Icons.home_filled,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.home_filled,
              color: Colors.red,
            ),
            label: 'Today',
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
              Icons.calendar_month_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.red,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.bar_chart_outlined,
              color: Colors.red,
            ),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_outlined,
              color: Colors.grey,
            ),
            activeIcon: Icon(
              Icons.menu_outlined,
              color: Colors.red,
            ),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
