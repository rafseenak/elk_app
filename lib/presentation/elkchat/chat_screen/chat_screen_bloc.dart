// ignore_for_file: avoid_print, library_prefixes

import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/user_entity.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_event.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  late IO.Socket socket;
  ApiClient apiClient = GetIt.I<ApiClient>();
  ChatScreenBloc()
      : super(const ChatScreenState(
            chatRoom: {},
            isBlockedByOther: null,
            isYouBlock: null,
            authUserId: null,
            otherUserId: null)) {
    connectSocket();

    on<SendMessageEvent>((event, emit) async {
      final messageData = {
        'authUserId': event.authUserId,
        'userId': event.userId,
        'message': event.message,
        'type': event.type,
        'file_name': event.file_name,
        'ad_id': event.ad?['adId'],
        'ad_name': event.ad?['adName'],
        'status': (event.type == 'system') ? 'blocked' : 'send'
      };

      final messageForShow = {
        'sender_id': event.authUserId,
        'reciever_id': event.userId,
        'message': event.message,
        'type': event.type,
        'file_name': event.file_name,
        'ad_id': event.ad?['adId'],
        'ad_name': event.ad?['adName'],
        'status': (event.type == 'system') ? 'blocked' : 'processing',
        'file_url': event.type == 'text'
            ? null
            : event.type == 'system'
                ? null
                : event.message
      };
      if (event.type != 'system') {
        emit(MessageSendStartState(
          chatRoom: state.chatRoom,
          newMessage: messageForShow,
          isBlockedByOther: state.isBlockedByOther,
          isYouBlock: state.isYouBlock,
          authUserId: state.authUserId,
          otherUserId: state.otherUserId,
        ));
        if (event.file_url != null) {
          final bytes = await event.file_url!.readAsBytes();
          final base64File = base64Encode(bytes);
          final mimeType = lookupMimeType(event.file_url!.path) ??
              'application/octet-stream';
          messageData['file'] = base64File;
          messageData['fileType'] = mimeType;
        }
      }
      socket.emit('sendMessage', messageData);
    });

    on<NewMessageEvent>((event, emit) {
      final currentChatRoom = Map<String, dynamic>.from(state.chatRoom);
      final currentChatData =
          Map<String, dynamic>.from(currentChatRoom['chat']);
      final List<dynamic> updatedChatMessages =
          List.from(currentChatData['chatMessages'] ?? []);
      updatedChatMessages.add(event.message);
      currentChatData['chatMessages'] = updatedChatMessages;
      final updatedChatRoom = {
        ...currentChatRoom,
        'chat': currentChatData,
      };
      socket.emit('updateMessageStatus',
          {'authUserId': state.authUserId, 'otherUserId': state.otherUserId});
      emit(ChatScreenLoaded(
          chatRoom: updatedChatRoom,
          isBlockedByOther: state.isBlockedByOther,
          isYouBlock: (event.message['type'] == 'system')
              ? !state.isYouBlock!
              : state.isYouBlock,
          authUserId: state.authUserId,
          otherUserId: state.otherUserId));
    });

    on<BlockEvent>((event, emit) async {
      try {
        Map<String, dynamic> result = await apiClient.isUserBlockedByOther(
            event.userId, event.authUserId);
        Map<String, dynamic> result2 = await apiClient.isUserBlockedByOther(
            event.authUserId, event.userId);
        emit(ChatScreenLoaded(
          chatRoom: state.chatRoom,
          isBlockedByOther: (result['status']) ? result['result'] : null,
          isYouBlock: (result2['status']) ? result2['result'] : null,
          authUserId: event.authUserId,
          otherUserId: event.userId,
        ));
      } catch (e) {
        emit(ChatScreenError(
          chatRoom: state.chatRoom,
          isBlockedByOther: state.isBlockedByOther,
          isYouBlock: state.isYouBlock,
          authUserId: event.authUserId,
          otherUserId: event.userId,
        ));
      }
    });

    on<LoadChatScreenEvent>((event, emit) async {
      Map<String, dynamic> result =
          await apiClient.isUserBlockedByOther(event.userId, event.authUserId);
      Map<String, dynamic> result2 =
          await apiClient.isUserBlockedByOther(event.authUserId, event.userId);

      emit(ChatScreenLoading(
        chatRoom: {},
        isBlockedByOther: (result['status']) ? result['result'] : null,
        isYouBlock: (result2['status']) ? result2['result'] : null,
        authUserId: event.authUserId,
        otherUserId: event.userId,
      ));
      final DataSet<UserEntity> authUser =
          await apiClient.getUser(event.authUserId);
      final DataSet<UserEntity> otherUser =
          await apiClient.getUser(event.userId);
      final Map<String, dynamic> chats =
          await apiClient.getChatsFromRoom(event.userId, event.authUserId);
      try {
        final Map<String, dynamic> chatScreenMessages = {
          'authUser': authUser.data!.toMap(),
          'otherUser': otherUser.data!.toMap(),
          'chat': chats.isNotEmpty ? chats['data'] : []
        };
        socket.emit('updateMessageStatus',
            {'authUserId': event.authUserId, 'otherUserId': event.userId});
        emit(ChatScreenLoaded(
            chatRoom: chatScreenMessages,
            isBlockedByOther: state.isBlockedByOther,
            isYouBlock: state.isYouBlock,
            authUserId: event.authUserId,
            otherUserId: event.userId));
      } catch (e) {
        emit(ChatScreenError(
            chatRoom: {},
            isBlockedByOther: state.isBlockedByOther,
            isYouBlock: state.isYouBlock,
            authUserId: event.authUserId,
            otherUserId: event.userId));
      }
    });
    on<TestEvent>((event, emit) {});
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

    socket.on('newMessage', (data) {
      add(NewMessageEvent(
        message: data,
      ));
    });

    socket.on('chatRoomCount', (data) {
      print('ChatRoomCount: $data');
    });
  }

  @override
  Future<void> close() {
    socket.dispose();
    return super.close();
  }
}
