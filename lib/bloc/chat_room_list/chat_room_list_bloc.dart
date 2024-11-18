// ignore_for_file: library_prefixes, avoid_print, invalid_use_of_visible_for_testing_member

import 'package:bloc/bloc.dart';
import 'chat_room_list_event.dart';
import 'chat_room_list_state.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatRoomListBloc extends Bloc<ChatRoomListEvent, ChatRoomListState> {
  late IO.Socket socket;
  final int? authUserId;
  ChatRoomListBloc({required this.authUserId})
      : super(ChatRoomListLoading([], 0, authUserId: authUserId)) {
    connectSocket();

    on<LoadChatRooms>((event, emit) async {
      emit(ChatRoomListLoading([], 0, authUserId: authUserId));
      try {
        socket.emit('getChatRooms', event.authUserId);
      } catch (e) {
        emit(ChatRoomListError("Failed to load chat rooms", [], 0,
            authUserId: authUserId));
      }
    });
  }

  void connectSocket() {
    socket = IO.io(
      'http://192.168.124.124:3000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to socket server');
    });
    socket.on('newMessage', (_) {
      // Emit LoadChatRooms event to refresh the chat room list
      add(LoadChatRooms(authUserId: state.authUserId));
    });
    socket.on('chatRooms', (data) {
      print('Received chatRooms data: $data');
      if (data != null) {
        emit(ChatRoomListLoaded(data, 0, authUserId: authUserId));
      } else {
        emit(ChatRoomListError("No chat rooms available", [], 0,
            authUserId: authUserId));
      }
    });
  }

  @override
  Future<void> close() {
    socket.dispose();
    return super.close();
  }
}
