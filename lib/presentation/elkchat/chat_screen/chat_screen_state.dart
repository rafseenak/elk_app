class ChatScreenState {
  final Map<String, dynamic> chatRoom;
  final bool? isBlockedByOther;
  final bool? isYouBlock;
  final int? authUserId;
  final int? otherUserId;
  const ChatScreenState({
    required this.chatRoom,
    required this.isBlockedByOther,
    required this.isYouBlock,
    required this.authUserId,
    required this.otherUserId,
  });
}

class ChatScreenLoading extends ChatScreenState {
  ChatScreenLoading(
      {required super.chatRoom,
      required super.isBlockedByOther,
      required super.isYouBlock,
      required super.authUserId,
      required super.otherUserId});
}

class ChatScreenLoaded extends ChatScreenState {
  ChatScreenLoaded(
      {required super.chatRoom,
      required super.isBlockedByOther,
      required super.isYouBlock,
      required super.authUserId,
      required super.otherUserId});
}

class MessageSendStartState extends ChatScreenState {
  final Map<String, dynamic> newMessage;
  MessageSendStartState(
      {required super.chatRoom,
      required this.newMessage,
      required super.isBlockedByOther,
      required super.isYouBlock,
      required super.authUserId,
      required super.otherUserId});
}

class ChatScreenError extends ChatScreenState {
  ChatScreenError(
      {required super.chatRoom,
      required super.isBlockedByOther,
      required super.isYouBlock,
      required super.authUserId,
      required super.otherUserId});
}
