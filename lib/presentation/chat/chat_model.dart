import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final List<int?> participants;
  final List<Map<String, dynamic>> chat;
  final Timestamp timestamp;
  Chat({
    required this.participants,
    required this.chat,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'chat': chat,
      'timestamp': timestamp,
    };
  }
}
