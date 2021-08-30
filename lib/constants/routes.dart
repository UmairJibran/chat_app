import 'package:chat_app/views/screens/all_chats.dart';
import 'package:chat_app/views/screens/chat_screen.dart';
import 'package:flutter/material.dart';

import '../views/screens/select_participant.dart';

class Routes {
  Route? onGeneratedRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (ctx) => AllChats(),
        );
      case SelectParticipant.routeName:
        return MaterialPageRoute(
          builder: (ctx) => SelectParticipant(),
        );
      case ChatScreenView.routeName:
        return MaterialPageRoute(
          builder: (ctx) => ChatScreenView(routeSettings.arguments as String),
        );
      default:
        return null;
    }
  }
}
