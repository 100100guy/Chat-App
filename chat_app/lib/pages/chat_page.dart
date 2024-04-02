// create a basic stateful Chat page

import 'dart:async';
import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/pages/full_image_screen.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.email, required this.uid})
      : super(key: key);

  final String email;
  final String uid;

  @override
  _ChatPageState createState() => _ChatPageState(this.email, this.uid);
}

class _ChatPageState extends State<ChatPage> {
  final String email;
  final String uid;
  final _chatService = ChatService();
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late StreamSubscription _messagesSubscription;
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  _ChatPageState(this.email, this.uid);

  File? _image;

  Future getImage() async {
    // add code to get image
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });

        uploadImage();
      }
    });
  }

  Future<void> uploadImage() async {
    String fileName = Uuid().v1();
    Message msg = Message(
      message: "",
      senderID: _authService.currentUser!.uid,
      senderEmail: _authService.currentUser!.email!,
      receiverID: uid,
      timestamp: Timestamp.now(),
      type: "img",
    );

    await _firestore
        .collection('chat_rooms')
        .doc(_chatService.getChatRoomId(uid))
        .collection('messages')
        .doc(fileName)
        .set(msg.toMap());

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(_image!).catchError((onError) async {
      await _firestore
          .collection('chat_rooms')
          .doc(_chatService.getChatRoomId(uid))
          .collection('messages')
          .doc(fileName)
          .delete();
    });
    String imageUrl = await uploadTask.ref.getDownloadURL();

    msg = Message(
      message: imageUrl,
      senderID: _authService.currentUser!.uid,
      senderEmail: _authService.currentUser!.email!,
      receiverID: uid,
      timestamp: Timestamp.now(),
      type: "img",
    );

    await _firestore
        .collection('chat_rooms')
        .doc(_chatService.getChatRoomId(uid))
        .collection('messages')
        .doc(fileName)
        .set(msg.toMap());
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(
        uid,
        _messageController.text,
        "text",
      );
      setState(() {
        _messageController.clear();
      });
    }
  }

  @override
  void initState() {
    print(email + " chat page" + uid);
    super.initState();
    _messagesSubscription = _chatService
        .getMessages(_authService.currentUser!.uid, uid)
        .listen((snapshot) {
      setState(() {
        _messages = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    _messagesSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Center(
            // Centering the text
            child: StreamBuilder(
              stream: _firestore.collection('Users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    email,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize:
                            20 // Changing text color to red (you can choose any color you want)
                        ),
                  );
                }
                final user = snapshot.data;
                return Text(
                  user!['name'] + " - " + user['status'],
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize:
                          20 // Changing text color to red (you can choose any color you want)
                      ),
                );
              },
            ),
          ),
        ),

        // add drawer
        drawer: MyDrawer(),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isCurrentUser =
                      message['senderID'] == _authService.currentUser!.uid;
                  return message['type'] == "text"
                      ? Container(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomLeft: isCurrentUser
                                    ? Radius.circular(20.0)
                                    : Radius.circular(0.0),
                                bottomRight: isCurrentUser
                                    ? Radius.circular(0.0)
                                    : Radius.circular(20.0),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  message['senderEmail'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomLeft: isCurrentUser
                                    ? Radius.circular(20.0)
                                    : Radius.circular(0.0),
                                bottomRight: isCurrentUser
                                    ? Radius.circular(0.0)
                                    : Radius.circular(20.0),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: isCurrentUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Handle tapping on the image here
                                    // For example, you can open the image in a full-screen view

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return FullScreenImage(
                                              imageUrl: message['message']);
                                        },
                                      ),
                                    );
                                  },
                                  child: message['message'] == ""
                                      ? CircularProgressIndicator()
                                      : Image.network(
                                          message['message'],
                                          width: 200,
                                          height: 200,
                                        ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  message['senderEmail'],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                ),
                              ],
                            ),
                          ),
                        );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () => getImage(), icon: Icon(Icons.photo)),
                  IconButton(
                    onPressed: sendMessage,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
