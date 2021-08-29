import 'package:chat_app/views/screens/all_chats.dart';
import 'package:chat_app/views/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import '../views/screens/select_participant.dart';

class Routes {
  static final Map<String, Widget Function(BuildContext)> routes = {
    AllChats.routeName: (contex) => AllChats(),
    SelectParticipant.routeName: (context) => SelectParticipant(),
    ChatScreenView.routeName: (context) => ChatScreenView(),
  };
}
