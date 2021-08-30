import 'dart:convert';
import 'dart:html';

import 'package:chat_app/views/screens/chat_screen.dart';
import 'package:chat_app/views/screens/select_participant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllChats extends StatefulWidget {
  static const String routeName = "/all-chats";

  const AllChats({
    Key? key,
  }) : super(key: key);

  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  var getAllChats;
  String? userId;

  Stream<QuerySnapshot>? fetchAllChats() {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    userId = FirebaseAuth.instance.currentUser!.uid;
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = _firestore
        .collection("chats")
        .where('chatParticipants', arrayContains: userId!)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
    return querySnapshot;
  }

  @override
  void initState() {
    getAllChats = fetchAllChats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Chats"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(SelectParticipant.routeName);
        },
        mini: true,
        child: Icon(
          Icons.message,
          color: Colors.white,
          size: 14,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAllChats,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("error: " + snapshot.error.toString());
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          }

          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              String? userName = docs[index]["chatParticipants"].first == userId
                  ? docs[index]["chatParticipants"][1]
                  : docs[index]["chatParticipants"].first;
              String? message = docs[index]["lastMessage"];
              return ListTile(
                title: Text(userName!),
                subtitle: Row(
                  children: [
                    Text(
                      message!.length > 20
                          ? message.replaceRange(20, message.length, "...")
                          : message,
                    ),
                    Spacer(),
                    Text(
                      DateFormat.yMMMMd().format(
                        DateTime.fromMillisecondsSinceEpoch(
                          docs[index]["lastMessageTime"],
                        ),
                      ),
                    )
                  ],
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.brown[200],
                  child: Center(
                    child: Text(
                      userName.characters.first,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ChatScreenView.routeName,
                    arguments: {
                      "participants": docs[index]["chatParticipants"]
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
