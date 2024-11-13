import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/presentation/chat/chat_service.dart';
import 'package:elk/presentation/chat/widgets/audio_bubble.dart';
import 'package:elk/presentation/chat/widgets/image_widget.dart';
import 'package:elk/presentation/chat/widgets/message_input.dart';
import 'package:elk/presentation/chat/widgets/video_message.dart';
import 'package:elk/presentation/widgets/error_widget.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int? userId;
  final int? authUserId;
  final Map<String, Map<String, dynamic>?> userdetails;
  final Map<String, dynamic> ad;
  const ChatScreen({
    super.key,
    required this.userId,
    required this.authUserId,
    required this.userdetails,
    required this.ad,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? authUser;
  Map<String, dynamic>? user;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    setAuthUser();
  }

  void setAuthUser() async {
    if (widget.authUserId == await widget.userdetails['user1']?['userId']) {
      authUser = widget.userdetails['user1'];
      user = widget.userdetails['user2'];
    } else {
      authUser = widget.userdetails['user2'];
      user = widget.userdetails['user1'];
    }
    setState(() {
      isLoading = false;
    });
  }

  String getTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('kk:mm').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (authUser?['isGuest'])
            ? Scaffold(
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/bg_chat.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 70),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              '${StringConstants.imageAssetsPath}/locked.png',
                              width: 100,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "You don't have permission to access this option",
                              textAlign: TextAlign.center,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                "Please sign in",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, RouteConstants.login);
                                },
                                child: const Text(
                                  "Sign in",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                appBar: _buildAppbar(context),
                body: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/bg_chat.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _buildMessageList1(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MessageInputWidget(
                        userId: widget.userId,
                        authUserId: widget.authUserId,
                        userDetails: {
                          'user': user,
                          'authUser': authUser,
                        },
                        ad: widget.ad,
                      ),
                    ),
                  ],
                ),
              );
  }

  AppBar _buildAppbar(
    BuildContext context,
  ) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              user?['profile'] ??
                  'https://static.vecteezy.com/system/resources/previews/018/765/757/original/user-profile-icon-in-flat-style-member-avatar-illustration-on-isolated-background-human-permission-sign-business-concept-vector.jpg',
            ),
            radius: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: Text(
                  user?['name'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // SizedBox(
              //   width: 180,
              //   child: Text(
              //     'Last seen. Today 12:30 pm',
              //     style: TextStyle(fontSize: 12, color: Colors.grey),
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList1() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _chatService.getChatStream1(widget.authUserId, widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: ErrorScreenWidget('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(localisation(context).noMessages));
        }
        final chatMessages = snapshot.data!['chat'];
        return ListView.builder(
          controller: _scrollController,
          itemCount: chatMessages.length + 1,
          itemBuilder: (context, index) {
            if (index == chatMessages.length) {
              return const SizedBox(height: 70);
            }
            return _buildMessageItem(chatMessages[index],
                key: ValueKey(chatMessages[index]['id']));
          },
        );
        // return ListView(
        //   controller: _scrollController,
        //   children: [
        //     ...snapshot.data!['chat']
        //         .map((document) => _buildMessageItem(document)),
        //     const SizedBox(height: 70),
        //   ],
        // );
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> chat, {Key? key}) {
    bool isSentByUser = (chat['senderId'] == widget.authUserId);
    Widget messageWidget;
    switch (chat['type']) {
      case 'text':
        messageWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
              chat['message']!,
              style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        );
        break;

      case 'image':
        messageWidget = Column(
          children: [
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
              fileName: chat['fileName'],
              appDirectory: chat['message']!,
              imageUrl: chat['fileUrl']!,
            ),
          ],
        );
        // messageWidget = ClipRRect(
        //   borderRadius: BorderRadius.circular(8.0),
        //   child: ClipRect(
        //     child: Image.network(chat['fileUrl']!),
        //     // child: Image.file(
        //     //   File(chat['message']!),
        //     //   fit: BoxFit.contain,
        //     // ),
        //   ),
        // );
        break;

      case 'video':
        messageWidget = Column(
          children: [
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: ClipRect(
                child: VideoMessageWidget(videoPath: chat['fileUrl']!),
                // child: VideoMessageWidget(videoPath: chat['message']!),
              ),
            ),
          ],
        );
        break;

      case 'file':
        messageWidget = Column(
          children: [
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
              fileName: chat['fileName'],
              appDirectory: chat['message']!,
              audioUrl: chat['fileUrl'],
            ),
          ],
        );
        break;

      default:
        messageWidget = Column(
          children: [
            (chat['adData'].isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(75, 161, 161, 161),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: 200,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteConstants.rentItem,
                            arguments: chat['adData']['adId']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '# ${chat['adData']['adId']}',
                              style: const TextStyle(
                                color: Constants.primaryColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: Text(
                              chat['adData']['adName'],
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
        isSentByUser, messageWidget, chat['timestamp'], chat['status']);
  }

  Widget buildChatMessage(
      bool isSentByUser, Widget msg, Timestamp timeStamp, String status) {
    String displayTime = getTime(timeStamp);
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSentByUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user?['profile'] ??
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
                              ? (authUser?['name'] ?? 'Unknown User')
                              : (user?['name'] ?? 'Unknown User'),
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
                          displayTime,
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
                    color: const Color.fromARGB(255, 255, 255, 255),
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
                            : Icons.check_circle_outline,
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
                  authUser?['profile'] ??
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
