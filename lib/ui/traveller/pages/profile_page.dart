import 'package:flutter/material.dart';
import 'package:nestiverse/gate.dart';
import 'package:nestiverse/ui/auth.dart';

import '../../../service/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "";

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    final user = await getUserProfile();
    setState(() {
      fullName = user["firstName"] + " " + user["lastName"];
    });
  }

  void _switchToHosting() async {
    await setUserMode("Host");
    _reload();
  }

  void _reload() {
    Navigator.pushReplacementNamed(context, Gate.route);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: const Icon(
                  Icons.account_circle,
                  size: 60,
                ),
                title: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  "Show profile",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right_sharp),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Settings",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.menu_book,
                  size: 25,
                ),
                title: const Text("Personal Information"),
                contentPadding: const EdgeInsets.all(0),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
              const Divider(height: 0),
              ListTile(
                onTap: () {},
                leading: const Icon(
                  Icons.verified_user_outlined,
                  size: 25,
                ),
                title: const Text("Login & security"),
                contentPadding: const EdgeInsets.all(0),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
              const Divider(height: 0),
              const SizedBox(height: 30),
              const Text(
                "Hosting",
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () {
                  _switchToHosting();
                },
                leading: const Icon(
                  Icons.compare_arrows_outlined,
                  size: 25,
                ),
                title: const Text("Switch to hosting"),
                contentPadding: const EdgeInsets.all(0),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
              ),
              const Divider(height: 0),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
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
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
