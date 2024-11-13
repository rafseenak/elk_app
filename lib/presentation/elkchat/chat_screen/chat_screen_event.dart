// ignore_for_file: non_constant_identifier_names

import 'dart:io';

abstract class ChatScreenEvent {
  const ChatScreenEvent();
}

class LoadChatScreenEvent extends ChatScreenEvent {
  final int authUserId;
  final int userId;

  const LoadChatScreenEvent({required this.authUserId, required this.userId});
}

class SendMessageEvent extends ChatScreenEvent {
  final int? authUserId;
  final int? userId;
  final String message;
  final String type;
  final String file_name;
  final File? file_url;
  final Map<String, dynamic>? ad;
  SendMessageEvent({
    required this.authUserId,
    required this.userId,
    required this.message,
    required this.type,
    required this.file_url,
    required this.file_name,
    required this.ad,
  });
}

class FetchMessagesEvent extends ChatScreenEvent {
  final int authUserId;
  final int userId;

  FetchMessagesEvent({
    required this.authUserId,
    required this.userId,
  });
}

class NewMessageEvent extends ChatScreenEvent {
  final Map<String, dynamic> message;

  NewMessageEvent({
    required this.message,
  });
}

class BlockEvent extends ChatScreenEvent {
  final int? authUserId;
  final int? userId;
  BlockEvent({
    required this.authUserId,
    required this.userId,
  });
}

class TestEvent extends ChatScreenEvent {}

class PreviousMessagesEvent extends ChatScreenEvent {
  final List<Map<String, dynamic>> messages;

  PreviousMessagesEvent({required this.messages});
}
