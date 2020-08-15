import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/chat_message.dart';
import 'package:flutterapp/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });

  }

  Future<FirebaseUser> _getUser() async{
    try{

      if(_currentUser != null) return _currentUser;

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential =
        GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = await authResult.user;

      return user;

    }
    catch(e){
      return null;
    }

  }

  void sendMessage({String text, File file}) async{

      final FirebaseUser user = await _getUser();

      if(user == null){
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
           content: Text("Algum erro ocorreu. Por favor, tente novamente."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      Map<String,dynamic> data = {"uid":user.uid,
        "sender":user.displayName,
        "senderPic":user.photoUrl,
        "time": Timestamp.now() };

      if(file != null){

        StorageUploadTask task = FirebaseStorage.instance.ref().child(
          DateTime.now().millisecondsSinceEpoch.toString() + user.uid
        ).putFile(file);

        setState(() {
          _isLoading = true;
        });

        StorageTaskSnapshot taskSnapshot = await task.onComplete;

        String url = await taskSnapshot.ref.getDownloadURL();

        data['imgURL'] = url;

      }

      setState(() {
        _isLoading = false;
      });

      if(text != null){
        data['text'] = text;
      }

      Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          _currentUser != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Deslogado com sucesso")
                  )
              );
            },
          )
              : Container()
        ],
        title: Text("SharedTalk"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection("messages").orderBy("time").snapshots(),
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child:CircularProgressIndicator());
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.documents.toList();

                      return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context,index){
                            return ChatMessage(
                                documents[index].data,
                                documents[index].data["uid"] == _currentUser?.uid ? true : false
                            );
                          }

                      );
                  }

                },
              ),
            ),
            _isLoading ? LinearProgressIndicator() : Container()
            ,
            TextComposer(
                sendMessage
            )
          ],
        ),
    );
  }
}
