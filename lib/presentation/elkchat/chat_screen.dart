// ignore_for_file: use_build_context_synchronously

import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/presentation/elkchat/audio_bubble.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_bloc.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_event.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_state.dart';
import 'package:elk/presentation/elkchat/image_widget.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_bloc.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_event.dart';
import 'package:elk/presentation/elkchat/widgets/message_input.dart';
import 'package:elk/presentation/elkchat/widgets/video_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int? userId;
  final int? authUserId;
  final Map<String, dynamic> ad;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.authUserId,
    required this.ad,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  ApiClient apiClient = GetIt.I<ApiClient>();
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatScreenBloc()
        ..add(LoadChatScreenEvent(
            authUserId: widget.authUserId!, userId: widget.userId!)),
      child: SafeArea(
        child: Scaffold(
          appBar: _buildAppbar(context),
          body: Stack(children: [
            BlocListener<ChatScreenBloc, ChatScreenState>(
              listener: (context, state) {
                context
                    .read<ChatScreenBloc>()
                    .socket
                    .emit('updateMessageStatus', {
                  'authUserId': state.authUserId,
                  'otherUserId': state.otherUserId,
                });
              },
              child: BlocBuilder<ChatScreenBloc, ChatScreenState>(
                builder: (context, state) {
                  if (state is ChatScreenLoading) {
                    return Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/bg_chat.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is ChatScreenLoaded ||
                      state is MessageSendStartState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/bg_chat.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: (state.chatRoom['chat']['chatMessages'].isEmpty)
                          ? Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'No Messages, Start Chating...',
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          : _buildMessageList(state.chatRoom),
                    );
                  } else if (state is ChatScreenError) {
                    return const Center(child: Text('Error'));
                  }
                  return Container();
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: MessageInputWidget(
                userId: widget.userId,
                authUserId: widget.authUserId,
                ad: widget.ad,
              ),
            )
          ]),
        ),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      actions: [
        BlocBuilder<ChatScreenBloc, ChatScreenState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'block':
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text((state.isYouBlock == true)
                              ? 'Unblock ${state.chatRoom['otherUser']['name']}'
                              : (state.isYouBlock == false)
                                  ? 'Block ${state.chatRoom['otherUser']['name']}'
                                  : 'Something Wrong try again.'),
                          content: Text((state.isYouBlock == true)
                              ? "Do you want to unblock ${state.chatRoom['otherUser']['name']}?"
                              : (state.isYouBlock == false)
                                  ? "Blocked user can't send you messages. Do you want to block ${state.chatRoom['otherUser']['name']}?"
                                  : ''),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () async {
                                bool? success = (state.isYouBlock == true)
                                    ? await apiClient.unBlockUser(
                                        widget.authUserId, widget.userId)
                                    : (state.isYouBlock == false)
                                        ? await apiClient.blockUser(
                                            widget.authUserId, widget.userId)
                                        : null;
                                if (success == true) {
                                  (state.isYouBlock == true)
                                      ? context.read<ChatScreenBloc>().add(
                                            SendMessageEvent(
                                              authUserId: widget.authUserId,
                                              userId: widget.userId,
                                              message:
                                                  'You unblocked this contact.',
                                              type: 'system',
                                              file_url: null,
                                              file_name: '',
                                              ad: null,
                                            ),
                                          )
                                      : (state.isYouBlock == false)
                                          ? context.read<ChatScreenBloc>().add(
                                                SendMessageEvent(
                                                  authUserId: widget.authUserId,
                                                  userId: widget.userId,
                                                  message:
                                                      'You blocked this contact.',
                                                  type: 'system',
                                                  file_url: null,
                                                  file_name: '',
                                                  ad: null,
                                                ),
                                              )
                                          : null;
                                  Fluttertoast.showToast(
                                    msg: (state.isYouBlock == true)
                                        ? "User Unblocked."
                                        : (state.isYouBlock == false)
                                            ? "User Blocked."
                                            : 'Something Wrong. Try again.',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Constants.accentColor,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "Something went wrong. Try again.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Constants.accentColor,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      context
                          .read<MessageInputBloc>()
                          .add(SetOptionFalseEvent());
                    },
                    value: 'block',
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<MessageInputBloc>()
                            .add(SetOptionFalseEvent());
                      },
                      child: Text((state.isYouBlock == true)
                          ? 'Unblock User'
                          : (state.isYouBlock == false)
                              ? 'Block User'
                              : ''),
                    ),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert),
            );
          },
        ),
      ],
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: BlocBuilder<ChatScreenBloc, ChatScreenState>(
        builder: (context, state) {
          if (state is ChatScreenLoading) {
            return const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        '',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (state is ChatScreenLoaded ||
              state is MessageSendStartState) {
            return Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    state.chatRoom['otherUser']['profile'] ??
                        'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg',
                  ),
                  radius: 22,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(
                        (state.chatRoom['otherUser']['name'] ?? 'User') ==
                                'User'
                            ? (state.chatRoom['otherUser']['userId'].toString())
                            : state.chatRoom['otherUser']['name'] ??
                                'Unknown User',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (state is ChatScreenError) {
            return const Center(child: Text('Error'));
          } else {
            return const Row();
          }
        },
      ),
    );
  }

  Widget _buildMessageList(Map<String, dynamic> chatMessages) {
    int messageCount = chatMessages['chat']['chatMessages'].length;

    return BlocBuilder<ChatScreenBloc, ChatScreenState>(
      builder: (context, state) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: messageCount + 2,
          itemBuilder: (context, index) {
            if (index < messageCount) {
              return _buildMessageItem(
                chatMessages['chat']['chatMessages'][index],
                chatMessages,
              );
            } else {
              if (index == messageCount) {
                return (state is MessageSendStartState)
                    ? _buildMessageItem(state.newMessage, chatMessages)
                    : const SizedBox();
              } else {
                return const SizedBox(height: 100);
              }
            }
          },
        );
      },
    );
  }

  String formatTimestampToHHMM(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    DateTime istTime = dateTime.add(const Duration(hours: 5, minutes: 30));
    return DateFormat('hh:mm a').format(istTime);
  }

  String convertToIST(String mysqlTimestamp) {
    DateTime utcTime = DateTime.parse(mysqlTimestamp);
    DateTime istTime = utcTime.subtract(const Duration(hours: 5, minutes: 30));
    return istTime.toString();
  }

  Widget _buildMessageItem(
      Map<String, dynamic> chat, Map<String, dynamic> allChat) {
    bool isSentByUser = (chat['sender_id'] == widget.authUserId);
    Widget messageWidget;
    switch (chat['type']) {
      case 'text':
        messageWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            Text(
              chat['message']! ?? '',
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
        break;

      case 'image':
        messageWidget = Column(
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            ImageMessageBubble(
              fileName: chat['file_name'] ?? '',
              appDirectory: chat['message']! ?? '',
              imageUrl: chat['file_url']! ?? '',
            ),
          ],
        );
        break;

      case 'video':
        messageWidget = Column(
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            // Text(chat['file_url']!)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: ClipRect(
                child: VideoMessageWidget(
                  videoPath: chat['file_url']!,
                ),
              ),
            ),
          ],
        );
        break;

      case 'file':
        messageWidget = Column(
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            GestureDetector(
              onTap: () {},
              child: Text(
                '📎 ${chat['message']!}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
        break;

      case 'audio':
        messageWidget = Column(
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            AudioMessageBubble(
              appDirectory: chat['message'],
              audioUrl: chat['file_url'],
              fileName: chat['file_name'],
            )
          ],
        );
        break;

      case 'system':
        messageWidget = Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                chat['message'],
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
        break;

      default:
        messageWidget = Column(
          children: [
            (chat['ad_id'] != null)
                ? Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['ad_id']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['ad_id']}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['ad_name'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            const Text('Unsupported message'),
          ],
        );
    }
    return buildChatMessage(
        isSentByUser,
        chat['type'],
        messageWidget,
        chat['createdAt'] ?? convertToIST(DateTime.now().toString()),
        chat['status'],
        allChat);
  }

  Widget buildChatMessage(bool isSentByUser, String type, Widget msg,
      String timeStamp, String status, Map<String, dynamic> allChat) {
    return (type == 'system')
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: msg,
          )
        : Container(
            margin: const EdgeInsets.only(top: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSentByUser) ...[
                  Container(
                    margin: const EdgeInsets.only(left: 15),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        allChat['otherUser']['profile'] ??
                            'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: isSentByUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isSentByUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Align(
                              alignment: isSentByUser
                                  ? Alignment.centerLeft
                                  : Alignment.centerLeft,
                              child: Text(
                                isSentByUser
                                    ? (allChat['authUser']['name'] == 'User')
                                        ? (allChat['authUser']['userId']
                                            .toString())
                                        : allChat['authUser']['name'] ?? 'User'
                                    : (allChat['otherUser']['name'] == 'User')
                                        ? allChat['otherUser']['userId']
                                            .toString()
                                        : allChat['otherUser']['name'] ??
                                            'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Align(
                              alignment: isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerRight,
                              child: Text(
                                formatTimestampToHHMM(timeStamp),
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 12.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        width: 200,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isSentByUser
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : const Color.fromRGBO(255, 255, 239, 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: msg,
                      ),
                      if (isSentByUser) ...[
                        const SizedBox(height: 4.0),
                        SizedBox(
                          width: 200,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              status == 'read'
                                  ? Icons.check_circle
                                  : status == 'send'
                                      ? Icons.check_circle_outline
                                      : Icons.circle_outlined,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSentByUser) ...[
                  const SizedBox(width: 8.0),
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        allChat['authUser']['profile'] ??
                            'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
