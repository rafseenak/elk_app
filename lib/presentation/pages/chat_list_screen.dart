import 'package:elk/presentation/chat/chat_screen.dart';
import 'package:elk/presentation/chat/chat_service.dart';
import 'package:elk/presentation/widgets/error_widget.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  final int? authUserId;
  ChatListScreen({
    super.key,
    required this.authUserId,
  });

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localisation(context).chat),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getChatRoomsStream(authUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: ErrorScreenWidget('Something went wrong'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(localisation(context).noChatAvailable));
          }

          final chatRooms = snapshot.data!;
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        (authUserId == chatRoom['authUser']['userId'])
                            ? (chatRoom['otherUser']['profile'] ??
                                'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg')
                            : (chatRoom['authUser']['profile'] ??
                                'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg'),
                      ),
                      radius: 25,
                    ),
                    title: Text(
                      (authUserId == chatRoom['authUser']['userId'])
                          ? chatRoom['otherUser']['name'] ?? ''
                          : chatRoom['authUser']['name'] ?? '',
                    ),
                    subtitle: Text(
                      (authUserId == chatRoom['authUser']['userId'])
                          ? chatRoom['otherUser']['decription'] ?? ''
                          : chatRoom['authUser']['decription'] ?? '',
                    ),
                    trailing: chatRoom['chatRoomData']['unreadCount'] > 0
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chatRoom['chatRoomData']['unreadCount']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId:
                                (authUserId == chatRoom['authUser']?['userId'])
                                    ? (chatRoom['otherUser']?['userId'])
                                    : (chatRoom['authUser']?['userId']),
                            authUserId: authUserId,
                            userdetails: {
                              "user1": chatRoom['otherUser'],
                              "user2": chatRoom['authUser'],
                            },
                            ad: const {},
                          ),
                        ),
                      );
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
        },
      ),
    );
  }
}
