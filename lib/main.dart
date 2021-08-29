import 'dart:async';

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
    if (_auth.currentUser == null) return await loginUser();
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
      home: FutureBuilder(
        future: checkLoginStatus,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) return AllChats(snapshot.data);
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
    _auth.signInAnonymously();
    return _auth.currentUser;
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}
