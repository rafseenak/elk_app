import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/user_entity.dart';
import 'package:elk/presentation/chat/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  ApiClient apiClient = GetIt.I<ApiClient>();

  Future<void> sendMessage(
    String message,
    String type,
    String fileName,
    String downloadUrl,
    int? userId,
    int? authUserId,
    Map<String, Map<String, dynamic>?> userDetails,
    Map<String, dynamic> ad,
  ) async {
    final Timestamp timestamp = Timestamp.now();
    var chatCollection = _firebaseFirestore.collection('chat_room');
    var querySnapshot = await chatCollection
        .where('participants', arrayContainsAny: [userId, authUserId]).get();

    QueryDocumentSnapshot<Map<dynamic, dynamic>>? chatDoc;

    for (var doc in querySnapshot.docs) {
      var participants = doc['participants'];
      if (participants.contains(userId) && participants.contains(authUserId)) {
        chatDoc = doc;
        break;
      }
    }
    if (chatDoc == null) {
      Chat newChat = Chat(
        participants: [authUserId, userId],
        chat: [
          {
            "message": message,
            "senderId": authUserId,
            "timestamp": timestamp,
            "recieverId": userId,
            "fileName": fileName,
            "fileUrl": downloadUrl,
            "type": type,
            "status": "send",
            "adData": ad
          }
        ],
        timestamp: timestamp,
      );
      await chatCollection.add(newChat.toMap());
    } else {
      await chatDoc.reference.update({
        'chat': FieldValue.arrayUnion([
          {
            "message": message,
            "senderId": authUserId,
            "timestamp": timestamp,
            "recieverId": userId,
            "fileName": fileName,
            "fileUrl": downloadUrl,
            "type": type,
            "status": "send",
            "adData": ad
          }
        ]),
        'timestamp': timestamp,
      });
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(int userId) async {
    try {
      final DataSet<UserEntity> userDataSet = await apiClient.getUser(userId);
      if (userDataSet.success && userDataSet.data != null) {
        return userDataSet.data!.toMap();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Stream<int?> countUnreadChatRooms(int? authUserId) async* {
    var chatCollection = _firebaseFirestore.collection('chat_room');
    while (true) {
      var querySnapshot = await chatCollection
          .where('participants', arrayContains: authUserId)
          .get();
      int unreadChatRoomsCount = 0;
      for (var doc in querySnapshot.docs) {
        var chatMessages = doc['chat'] as List<dynamic>;
        bool hasUnreadMessages = chatMessages.any((message) {
          return message['status'] == 'send' &&
              message['recieverId'] == authUserId;
        });
        if (hasUnreadMessages) {
          unreadChatRoomsCount++;
        }
      }
      yield unreadChatRoomsCount;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<Map<String, dynamic>?> getChatStream1(int? authUserId, int? userId) {
    return _firebaseFirestore
        .collection('chat_room')
        .where('participants', arrayContains: authUserId)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
      List<Map<String, dynamic>> filteredMessages =
          snapshot.docs.where((DocumentSnapshot doc) {
        final participants = List<int>.from(doc['participants']);
        return participants.contains(userId);
      }).map((DocumentSnapshot doc) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'chatRoomId': doc.id,
        };
      }).toList();
      filteredMessages.sort((a, b) {
        final timestampA = (a['timestamp'] as Timestamp).toDate();
        final timestampB = (b['timestamp'] as Timestamp).toDate();
        return timestampA.compareTo(timestampB);
      });
      if (filteredMessages.isNotEmpty) {
        String chatRoomId = filteredMessages[0]['chatRoomId'];
        await markMessagesAsRead(chatRoomId, authUserId);
        return filteredMessages[0];
      }
      return null;
    });
  }

  Future<void> markMessagesAsRead(String chatRoomId, int? userId) async {
    var chatRoomDoc =
        await _firebaseFirestore.collection('chat_room').doc(chatRoomId).get();
    if (chatRoomDoc.exists) {
      var chatData = chatRoomDoc.data() as Map<String, dynamic>;
      var chatMessages = chatData['chat'] as List<dynamic>;
      List<Map<String, dynamic>> updatedMessages = [];
      for (var message in chatMessages) {
        if (message['recieverId'] == userId && message['status'] == 'send') {
          message['status'] = 'read';
        }
        updatedMessages.add(message);
      }
      await _firebaseFirestore.collection('chat_room').doc(chatRoomId).update({
        'chat': updatedMessages,
      });
    }
  }

  Stream<List<Map<String, dynamic>>> getChatRoomsStream(int? authUserId) {
    return _firebaseFirestore
        .collection('chat_room')
        .where('participants', arrayContains: authUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
      List<Map<String, dynamic>> chatRooms = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var chatMessages = data['chat'] as List<dynamic>;
        int unreadCount = 0;
        for (var message in chatMessages) {
          if (message['status'] == 'send' &&
              message['recieverId'] == authUserId) {
            unreadCount++;
          }
        }
        data['unreadCount'] = unreadCount;
        Map<String, dynamic>? authUserData;
        Map<String, dynamic>? otherUserData;
        if (authUserId != null) {
          authUserData = await fetchUserData(authUserId);
        }
        List<int?> participants = List<int?>.from(data['participants'] ?? []);
        for (var participantId in participants) {
          if (participantId != authUserId) {
            otherUserData = await fetchUserData(participantId!);
          }
        }
        Map<String, dynamic> chatRoomWithUser = {
          'chatRoomData': data,
          'authUser': authUserData,
          'otherUser': otherUserData,
        };
        chatRooms.add(chatRoomWithUser);
      }
      return chatRooms;
    });
  }
}
