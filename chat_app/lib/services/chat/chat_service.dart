import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatService {
  // get instance of firestore

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getChatStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(
    String receiverId,
    message,
  ) async {
    // get the current user info

    final String currentId = _auth.currentUser!.uid;
    final String currentEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message msg = Message(
      message: message,
      senderID: currentId,
      senderEmail: currentEmail,
      receiverID: receiverId,
      timestamp: timestamp,
    );

    //construct chat room id for two users (sorted to ensure uniqueness)
    List<String> ids = [currentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    //add msg to db
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(msg.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String currentId, String receiverId) {
    //construct chat room id for two users (sorted to ensure uniqueness)
    List<String> ids = [currentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
