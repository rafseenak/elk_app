abstract class ChatRoomListState {
  final List chatRooms;
  final int count;
  final int? authUserId;

  ChatRoomListState(this.chatRooms, this.count, {required this.authUserId});
}

class ChatRoomListLoading extends ChatRoomListState {
  ChatRoomListLoading(super.chatRooms, super.count,
      {required super.authUserId});
}

class ChatRoomListLoaded extends ChatRoomListState {
  ChatRoomListLoaded(super.chatRooms, super.count, {required super.authUserId});
}

class ChatRoomListError extends ChatRoomListState {
  final String message;

  ChatRoomListError(this.message, super.chatRooms, super.count,
      {required super.authUserId});
}
