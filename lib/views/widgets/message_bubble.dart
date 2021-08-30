import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool? isMe;
  final String? message;
  final String? time;
  const MessageBubble({
    Key? key,
    this.isMe,
    this.message,
    this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color appcolor = Color(0xff006600);
    if (isMe!) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: appcolor.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(message!),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    time!,
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text(
                        message!,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    time!,
                    style: TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
