abstract class ChatRoomListState {
  final List chatRooms;
  final int count;

  ChatRoomListState(this.chatRooms, this.count);
}

class ChatRoomListLoading extends ChatRoomListState {
  ChatRoomListLoading(super.chatRooms, super.count);
}

class ChatRoomListLoaded extends ChatRoomListState {
  ChatRoomListLoaded(super.chatRooms, super.count);
}

class ChatRoomListError extends ChatRoomListState {
  final String message;

  ChatRoomListError(this.message, super.chatRooms, super.count);
}
