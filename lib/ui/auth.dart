import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nestiverse/gate.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  static const route = "/auth";

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  DateTime birthDate = DateTime.now();
  TextEditingController conFirstName = TextEditingController();
  TextEditingController conLastName = TextEditingController();
  TextEditingController conBirthDate = TextEditingController();
  TextEditingController conEmail = TextEditingController();
  TextEditingController conPassword = TextEditingController();

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != birthDate) {
      setState(() {
        birthDate = picked;
        conBirthDate.text = birthDate.toString().split(" ")[0];
      });
    }
  }

  void createAccount() async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: conEmail.text,
        password: conPassword.text,
      );

      final user = <String, dynamic>{
        "firstName": conFirstName.text,
        "lastName": conLastName.text,
        "birthdate": birthDate.millisecondsSinceEpoch.toString(),
        "email": conEmail.text,
        "uid": credential.user!.uid,
        "mode": "Traveller",
      };
      await db.collection("users").doc(credential.user!.uid).set(user);
      // Navigator.pushReplacementNamed(context, Gate.route);
      _switchTo(Gate.route);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showMessage("Password should be at least 6 characters");
      } else if (e.code == 'email-already-in-use') {
        showMessage("Email already exists");
      } else {
        showMessage("Something went wrong");
      }
    } catch (e) {
      showMessage("Something badly wrong");
    }
  }

  void signIn() async {
    try {
      await auth.signInWithEmailAndPassword(
        email: conEmail.text,
        password: conPassword.text,
      );
      // Navigator.pushReplacementNamed(context, Gate.route);
      _switchTo(Gate.route);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        showMessage("Invalid email or password");
      } else {
        showMessage("Something went wrong");
      }
    } catch (e) {
      showMessage("Something badly wrong");
    }
  }

  void _switchTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Login or sign up to Nestiverse",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                    visible: !isLogin,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Column(
                        children: [
                          TextField(
                            controller: conFirstName,
                            decoration: const InputDecoration(
                              labelText: "First Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: conLastName,
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: conBirthDate,
                            onTap: () {
                              _selectDate(context);
                            },
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Birthday",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )),
                TextField(
                  controller: conEmail,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: conPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
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
                    if (isLogin) {
                      signIn();
                    } else {
                      createAccount();
                    }
                  },
                  child: Text(
                    isLogin ? "LOGIN" : "SIGN UP",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                const Center(
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pink,
                    side: const BorderSide(color: Colors.pink),
                    fixedSize: const Size(double.maxFinite, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                      if (!isLogin) {
                        _controller.forward();
                      } else {
                        _controller.reverse();
                      }
                    });
                  },
                  child: Text(
                    isLogin ? "SIGN UP" : "LOGIN",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
