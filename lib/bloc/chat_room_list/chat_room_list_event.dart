abstract class ChatRoomListEvent {}

class LoadChatRooms extends ChatRoomListEvent {
  final int? authUserId;
  LoadChatRooms({
    required this.authUserId,
  });
}
