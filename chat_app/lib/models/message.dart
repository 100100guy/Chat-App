import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final Timestamp timestamp;

  Message({
    required this.message,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'timestamp': timestamp,
    };
  }
}
