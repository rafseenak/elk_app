import 'package:elk/bloc/chat_room_list/chat_room_list_bloc.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_event.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_state.dart';
import 'package:elk/presentation/elkchat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elk/utils/cutom_utils.dart';

class ChatRoomList extends StatelessWidget {
  final int? authUserId;

  const ChatRoomList({Key? key, required this.authUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRoomListBloc(authUserId: authUserId)
        ..add(LoadChatRooms(
          authUserId: authUserId,
        )),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localisation(context).chat),
        ),
        body: BlocBuilder<ChatRoomListBloc, ChatRoomListState>(
          builder: (context, state) {
            if (state is ChatRoomListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatRoomListLoaded) {
              return (state.chatRooms.isEmpty)
                  ? Center(
                      child: Text(localisation(context).noChatAvailable),
                    )
                  : ListView.builder(
                      itemCount: state.chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = state.chatRooms[index];
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  chatRoom['otherUser']['profile'] ??
                                      'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg',
                                ),
                                radius: 25,
                              ),
                              title: Text(chatRoom['otherUser']['name'] ?? ''),
                              subtitle: Text(
                                  chatRoom['otherUser']['description'] ?? ''),
                              trailing: chatRoom['new_message_count'] != 0
                                  ? Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        chatRoom['new_message_count']
                                            .toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            userId: chatRoom['otherUser']
                                                ['user_id'],
                                            authUserId: authUserId,
                                            ad: const {},
                                          )),
                                ).then((value) {
                                  context.read<ChatRoomListBloc>().add(
                                        UpdateChatRoomNewMessageCount(
                                          chatRoomIndex: index,
                                          newMessageCount: 0,
                                        ),
                                      );
                                });
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ],
                        );
                      },
                    );
            } else if (state is ChatRoomListError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("Something went wrong"));
            }
          },
        ),
      ),
    );
  }
}
