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
  TextEditingController? _messageController = new TextEditingController();
  FocusNode _messageFocusNode = new FocusNode();

  void sendMessage(String? message) {
    setState(() {
      _messageController!.clear();
    });
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    _firestore
        .collection("chats")
        .doc(widget.chatId)
        .collection("conversation")
        .add({
      "seen": false,
      "content": message,
      "sender": userId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
    _firestore.collection("chats").doc(widget.chatId).update({
      "lastMessage": message,
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      "lastMessageSender": userId,
    });
  }

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
    _messageFocusNode.requestFocus();
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
            child: Column(
              children: [
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 05, horizontal: 20),
                    child: ListView.builder(
                      reverse: false,
                      shrinkWrap: true,
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
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            cursorColor: Colors.black,
                            focusNode: _messageFocusNode,
                            controller: _messageController,
                            onEditingComplete: () =>
                                sendMessage(_messageController!.text),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type Here",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => sendMessage(_messageController!.text),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
