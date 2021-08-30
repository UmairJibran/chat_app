import 'package:chat_app/views/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreenView extends StatefulWidget {
  static const String routeName = "chat-screen";
  const ChatScreenView(this.chatId, {Key? key}) : super(key: key);

  final String? chatId;

  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  var userId;
  var getAllConverations;

  Stream<QuerySnapshot> fetchConversation() {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshot = _firestore
        .collection("chats")
        .doc(widget.chatId)
        .collection("conversation")
        .orderBy('timestamp', descending: false)
        .snapshots();
    return querySnapshot;
  }

  @override
  initState() {
    getAllConverations = fetchConversation();
    userId = FirebaseAuth.instance.currentUser?.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAllConverations,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("error: " + snapshot.error.toString());
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LinearProgressIndicator();
          }
          List<DocumentSnapshot> docs = snapshot.data!.docs;
          return Container(
            padding: EdgeInsets.symmetric(vertical: 05, horizontal: 20),
            child: ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                String? content = docs[index]["content"];
                int? timestamp = docs[index]["timestamp"];
                String? sender = docs[index]["sender"];
                return MessageBubble(
                  isMe: sender == userId,
                  time: DateFormat.Hm().format(
                    DateTime.fromMillisecondsSinceEpoch(timestamp!),
                  ),
                  message: content,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
