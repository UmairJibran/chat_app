import 'dart:async';

import 'package:chat_app/constants/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'views/screens/all_chats.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var checkLoginStatus;

  Future<dynamic>? isUserLoggedIn() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    // logout user by uncommenting the following line
    // await _auth.signOut();
    if (_auth.currentUser == null) {
      User user = await loginUser();
      await storeInFirestore(user);
      return user;
    }
    return _auth.currentUser;
  }

  @override
  initState() {
    checkLoginStatus = isUserLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Realtime Chat Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      routes: Routes.routes,
      home: FutureBuilder(
        future: checkLoginStatus,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) return AllChats();
          }
          return Scaffold(
            body: Container(
              child: Center(
                child: Column(
                  children: [
                    Spacer(flex: 3),
                    Text("Loading..."),
                    Spacer(),
                    CircularProgressIndicator(),
                    Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic>? loginUser() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signInAnonymously();
    return _auth.currentUser;
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}

Future<void>? storeInFirestore(User user) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  await _firestore.collection("users").doc(user.uid).set({
    "createdAt": DateTime.now().millisecondsSinceEpoch,
  });
}
