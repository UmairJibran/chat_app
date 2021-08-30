import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class SelectParticipant extends StatefulWidget {
  static const String routeName = "/participant-selection";
  const SelectParticipant({Key? key}) : super(key: key);

  @override
  _SelectParticipantState createState() => _SelectParticipantState();
}

class _SelectParticipantState extends State<SelectParticipant> {
  var loadParticipants;

  Future<List<String?>>? fetchParticipants() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> allUsers =
        await _firestore.collection("users").get();
    List<String?> userIds = [];
    allUsers.docs.forEach((user) {
      if (user.id != FirebaseAuth.instance.currentUser?.uid)
        userIds.add(user.id);
      // if user has the number saved do not push it to the array `userIds`
    });
    return userIds;
  }

  Future<void> beginConversation(String otherUserId) async {
    String? convoId;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var conversation = await _firestore.collection("chats").where(
        "chatParticipants",
        isEqualTo: [FirebaseAuth.instance.currentUser?.uid, otherUserId]).get();
    if (conversation.docs.isEmpty) {
      DocumentReference ref = _firestore.collection("chats").doc();
      await ref.set({
        "chatParticipants": [
          FirebaseAuth.instance.currentUser?.uid,
          otherUserId
        ],
        "conversationStartedBy": FirebaseAuth.instance.currentUser?.uid,
        "lastMessage": "Just Started",
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
        "lastMessageSender": FirebaseAuth.instance.currentUser?.uid,
      });
      convoId = ref.id;
    } else {
      convoId = conversation.docs.first.id;
    }
    Navigator.of(context).pushNamed(
      ChatScreenView.routeName,
      arguments: convoId,
    );
  }

  @override
  void initState() {
    loadParticipants = fetchParticipants();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Participants"),
      ),
      body: FutureBuilder(
        future: loadParticipants,
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<String?> userIds = snapshot.data;
              return ListView.builder(
                itemCount: userIds.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(userIds[index] ?? ""),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    onTap: () => beginConversation(userIds[index] ?? ""),
                  );
                },
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
