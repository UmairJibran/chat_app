import 'dart:convert';

import 'package:chat_app/views/screens/chat_screen.dart';
import 'package:chat_app/views/screens/select_participant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllChats extends StatefulWidget {
  static final String routeName = "/all-chats";

  const AllChats({
    Key? key,
  }) : super(key: key);

  @override
  _AllChatsState createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  var getAllChats;
  String? userId;

  Future<List<Map<String, dynamic>>>? fetchAllChats() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot? querySnapshot = await _firestore
        .collection("chats")
        .where('chatParticipants', arrayContains: userId!)
        .get();
    List<Map<String, dynamic>> chats = [];
    querySnapshot.docs.forEach((element) {
      var chat = json.encode(element.data());
      print(chat);
      chats.add(
        {
          "chatParticipants": json.decode(chat)["chatParticipants"],
          "lastMessage": json.decode(chat)["lastMessage"],
          "lastMessageTime": DateTime.fromMillisecondsSinceEpoch(
            json.decode(chat)["lastMessageTime"],
          ),
          "lastMessageSender": json.decode(chat)["lastMessageSender"],
        },
      );
    });
    return chats;
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
      body: FutureBuilder(
        future: getAllChats,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String? userName =
                    snapshot.data![index]["chatParticipants"][0] == userId
                        ? snapshot.data![index]["chatParticipants"][1]
                        : snapshot.data![index]["chatParticipants"][0];
                String? message = (snapshot.data![index]["lastMessage"] +
                        snapshot.data![index]["lastMessage"] +
                        snapshot.data![index]["lastMessage"])
                    .toString();
                return ListTile(
                  title: Text(userName!),
                  subtitle: Row(
                    children: [
                      Text(
                        message.length > 20
                            ? message.replaceRange(20, message.length, "...")
                            : message,
                      ),
                      Spacer(),
                      Text(snapshot.data![index]["lastMessageTime"].toString()),
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
                        "participants": snapshot.data![index]
                            ["chatParticipants"]
                      },
                    );
                  },
                );
              },
            );
          }
          return LinearProgressIndicator();
        },
      ),
    );
  }
}
