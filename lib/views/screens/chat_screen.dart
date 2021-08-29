import 'package:flutter/material.dart';

class ChatScreenView extends StatefulWidget {
  static final String routeName = "chat-screen";
  const ChatScreenView({Key? key}) : super(key: key);

  @override
  _ChatScreenViewState createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  var participants;

  @override
  Widget build(BuildContext context) {
    participants = ModalRoute.of(context)!.settings.arguments;
    print(participants);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: Text(participants["participants"].toString()),
        ),
      ),
    );
  }
}
