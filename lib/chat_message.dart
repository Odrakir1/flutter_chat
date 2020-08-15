import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data,this.mine);
  final bool mine;

  final Map<String,dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
      child: Row(
        children: <Widget>[
          !mine ?
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                data["senderPic"]
              ),
            ),
          ) : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                data["imgURL"] != null ?
                    Image.network(data["imgURL"],width: 250,
                    ) :
                    Text(data["text"],
                    style: TextStyle(fontSize: 18.0),
                    textAlign: mine ? TextAlign.end : TextAlign.start,
                    ),
                Text(
                  data["sender"],
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          mine ?
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  data["senderPic"]
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
