import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/ui/host/pages/calendar_page.dart';
import 'package:nestiverse/ui/host/pages/insights_page.dart';
import 'package:nestiverse/ui/host/pages/menu_page.dart';
import 'package:nestiverse/ui/host/pages/now_page.dart';

import '../traveller/pages/inbox_page.dart';

class HostUi extends StatefulWidget {
  const HostUi({super.key});

  static const route = "/ui/host";

  @override
  State<HostUi> createState() => _HostUiState();
}

class _HostUiState extends State<HostUi> {
  final db = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    NowPage(),
    InboxPage(),
    CalendarPage(),
    InsightsPage(),
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
            label: 'Now',
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
