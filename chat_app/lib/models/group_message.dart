import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String message;
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final Timestamp timestamp;
  final String type;

  GroupMessage({
    required this.message,
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'timestamp': timestamp,
      'type': type,
    };
  }
}
