// create a basic stateful Chat page

import 'dart:async';
import 'dart:io';

import 'package:chat_app/models/group_message.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/pages/full_image_screen.dart';
import 'package:chat_app/pages/groups/group_info.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({Key? key, required this.name, required this.gcid})
      : super(key: key);

  final String name;
  final String gcid;

  @override
  _GroupChatPageState createState() =>
      _GroupChatPageState(this.name, this.gcid);
}

class _GroupChatPageState extends State<GroupChatPage> {
  final String name;
  final String gcid;
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  late StreamSubscription _messagesSubscription;
  List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  _GroupChatPageState(this.name, this.gcid);

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
    GroupMessage msg = GroupMessage(
      message: "",
      senderID: _authService.currentUser!.uid,
      senderEmail: _authService.currentUser!.email!,
      receiverID: gcid,
      timestamp: Timestamp.now(),
      type: "img",
    );

    await _firestore
        .collection('groups')
        .doc(gcid)
        .collection('chats')
        .doc(fileName)
        .set(msg.toMap());

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(_image!).catchError((onError) async {
      await _firestore
          .collection('groups')
          .doc(gcid)
          .collection('chats')
          .doc(fileName)
          .delete();
    });
    String imageUrl = await uploadTask.ref.getDownloadURL();

    msg = GroupMessage(
      message: imageUrl,
      senderID: _authService.currentUser!.uid,
      senderEmail: _authService.currentUser!.email!,
      receiverID: gcid,
      timestamp: Timestamp.now(),
      type: "img",
    );

    await _firestore
        .collection('groups')
        .doc(gcid)
        .collection('chats')
        .doc(fileName)
        .set(msg.toMap());
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      GroupMessage msg = GroupMessage(
        message: _messageController.text,
        senderID: _authService.currentUser!.uid,
        senderEmail: _authService.currentUser!.email!,
        receiverID: gcid,
        timestamp: Timestamp.now(),
        type: "text",
      );

      await _firestore
          .collection('groups')
          .doc(gcid)
          .collection('chats')
          .add(msg.toMap());
      setState(() {
        _messageController.clear();
      });
    }
  }

  @override
  void initState() {
    print(name + " chat page" + gcid);
    super.initState();

    _messagesSubscription = _firestore
        .collection('groups')
        .doc(gcid)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots()
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
              child: Text(
            name,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 20),
          )),
          actions: [
            IconButton(
              onPressed: () {
                print("Group Info");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return GroupInfo(groupId: gcid, groupName: name);
                    },
                  ),
                );
              },
              icon: Icon(Icons.info,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ],
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
                  if (message['type'] == "text") {
                    return Container(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                    );
                  } else if (message['type'] == "img") {
                    return Container(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  } else if (message['type'] == "notify") {
                    return Container(
                      alignment: Alignment.center,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              message['message'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  ;
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
