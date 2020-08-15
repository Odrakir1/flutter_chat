import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class TextComposer extends StatefulWidget {

  TextComposer(this.sendText);

  final Function({String text, File file}) sendText;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  bool _isComposing = false;
  TextEditingController _text = TextEditingController();
  final picker = ImagePicker();
  File image;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child:
      Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
                Icons.photo_camera
            ),
            onPressed: () async{
              final pickedFile = await picker.getImage(source: ImageSource.gallery);

              if(pickedFile == null) return;
              setState(() {
                image = File(pickedFile.path);
                widget.sendText(file: image);
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _text,
              decoration: InputDecoration.collapsed(hintText: "Escrever mensagem"),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendText(text: text);
                _text.clear();
                setState(() {
                  _isComposing = false;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing ? (){
                widget.sendText(text: _text.text);
                _text.clear();
                setState(() {
                  _isComposing = false;
                });
            } : null,
          )
        ],
      ),
    );
  }
}
