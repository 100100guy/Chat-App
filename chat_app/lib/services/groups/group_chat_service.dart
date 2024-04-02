import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GroupChatService {
  // get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<DocumentSnapshot>> getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get();
    return querySnapshot.docs;
  }
}
