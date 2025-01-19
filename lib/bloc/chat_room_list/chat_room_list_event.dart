abstract class ChatRoomListEvent {}

class LoadChatRooms extends ChatRoomListEvent {
  final int? authUserId;
  LoadChatRooms({
    required this.authUserId,
  });
}

class UpdateChatRoomNewMessageCount extends ChatRoomListEvent {
  final int chatRoomIndex;
  final int newMessageCount;

  UpdateChatRoomNewMessageCount({
    required this.chatRoomIndex,
    required this.newMessageCount,
  });
}
