// ignore_for_file:  use_build_context_synchronously, unused_local_variable, unused_element

import 'package:elk/constants.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_bloc.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_event.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_state.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_bloc.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_event.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elk/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:elk/utils/cutom_utils.dart';

class MessageInputWidget extends StatefulWidget {
  final int? userId;
  final int? authUserId;
  final Map<String, dynamic> ad;

  const MessageInputWidget({
    super.key,
    required this.userId,
    required this.authUserId,
    required this.ad,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  TextEditingController messageController = TextEditingController();
  ApiClient apiClient = GetIt.I<ApiClient>();

  @override
  Widget build(BuildContext context) {
    final isAdTag = widget.ad.isNotEmpty;

    return BlocProvider(
      create: (context) => MessageInputBloc(navigatorKey, isAdTag: isAdTag),
      child: BlocBuilder<MessageInputBloc, MessageInputState>(
        builder: (context, state) {
          final bloc = context.read<MessageInputBloc>();

          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Container(
                  //   height: bloc.mainContainerHeight,
                  //   margin:
                  //       const EdgeInsets.only(left: 15, right: 4, bottom: 15),
                  //   padding: const EdgeInsets.all(2),
                  //   decoration: const BoxDecoration(
                  //     borderRadius: BorderRadius.all(Radius.circular(35)),
                  //     color: Colors.amber,
                  //   ),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       if (bloc.showOptions)
                  //         Column(
                  //           children: [
                  //             BlocListener<MessageInputBloc, MessageInputState>(
                  //               listener: (context, state) {
                  //                 final isAdTag1 = context
                  //                     .read<MessageInputBloc>()
                  //                     .state
                  //                     .isAdTag;
                  //                 if (state is UploadCompleteStateCamera) {
                  //                   context
                  //                       .read<MessageInputBloc>()
                  //                       .add(ClearAdTagEvent());
                  //                   context.read<ChatScreenBloc>().add(
                  //                         SendMessageEvent(
                  //                           authUserId: widget.authUserId,
                  //                           userId: widget.userId,
                  //                           message: state.path,
                  //                           type: 'image',
                  //                           file_url: state.file,
                  //                           file_name: state.message,
                  //                           ad: isAdTag1 ? widget.ad : null,
                  //                         ),
                  //                       );
                  //                   // context
                  //                   //     .read<MessageInputBloc>()
                  //                   //     .add(SetOptionFalseEvent());
                  //                 }
                  //               },
                  //               child: _buildOptionButton(
                  //                 icon: Icons.camera_outlined,
                  //                 onPressed: () {
                  //                   context
                  //                       .read<MessageInputBloc>()
                  //                       .add(OpenCameraEvent());
                  //                 },
                  //               ),
                  //             ),
                  //             BlocListener<MessageInputBloc, MessageInputState>(
                  //               listener: (context, state) {
                  //                 final isAdTag1 = context
                  //                     .read<MessageInputBloc>()
                  //                     .state
                  //                     .isAdTag;
                  //                 if (state is UploadCompleteStateImage) {
                  //                   context
                  //                       .read<MessageInputBloc>()
                  //                       .add(ClearAdTagEvent());
                  //                   context.read<ChatScreenBloc>().add(
                  //                         SendMessageEvent(
                  //                           authUserId: widget.authUserId,
                  //                           userId: widget.userId,
                  //                           message: state.path,
                  //                           type: 'image',
                  //                           file_url: state.file,
                  //                           file_name: state.message,
                  //                           ad: isAdTag1 ? widget.ad : null,
                  //                         ),
                  //                       );
                  //                 }
                  //               },
                  //               child: _buildOptionButton(
                  //                 icon: Icons.image_outlined,
                  //                 onPressed: () {
                  //                   // context
                  //                   //     .read<MessageInputBloc>()
                  //                   //     .add(SetOptionFalseEvent());
                  //                   context
                  //                       .read<MessageInputBloc>()
                  //                       .add(PickFileEvent(false));
                  //                 },
                  //               ),
                  //             ),
                  //             // BlocListener<MessageInputBloc, MessageInputState>(
                  //             //   listener: (context, state) {
                  //             //     final isAdTag1 = context
                  //             //         .read<MessageInputBloc>()
                  //             //         .state
                  //             //         .isAdTag;
                  //             //     if (state is UploadCompleteStateVideo) {
                  //             //       context
                  //             //           .read<MessageInputBloc>()
                  //             //           .add(ClearAdTagEvent());
                  //             //       context.read<ChatScreenBloc>().add(
                  //             //             SendMessageEvent(
                  //             //               authUserId: widget.authUserId,
                  //             //               userId: widget.userId,
                  //             //               message: state.path,
                  //             //               type: 'video',
                  //             //               file_url: state.file,
                  //             //               file_name: state.message,
                  //             //               ad: isAdTag1 ? widget.ad : null,
                  //             //             ),
                  //             //           );
                  //             //     }
                  //             //   },
                  //             //   child: _buildOptionButton(
                  //             //     icon: Icons.videocam_outlined,
                  //             //     onPressed: () {
                  //             //       context
                  //             //           .read<MessageInputBloc>()
                  //             //           .add(SetOptionFalseEvent());
                  //             //       context
                  //             //           .read<MessageInputBloc>()
                  //             //           .add(PickFileEvent(true));
                  //             //     },
                  //             //   ),
                  //             // ),
                  //           ],
                  //         ),
                  //       _buildToggleOptionsButton(context),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(width: 15),
                  _buildMessageTextField(context, state),
                  _buildMicButton(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(2),
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: IconButton(
        color: Colors.black,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildToggleOptionsButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: BlocBuilder<ChatScreenBloc, ChatScreenState>(
        builder: (context, state) {
          return IconButton(
            icon: Icon(context.watch<MessageInputBloc>().showOptions
                ? Icons.close
                : Icons.add),
            onPressed: () {
              if (state.isYouBlock == true) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('Unblock the user to send message.'),
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
                            bool success = await apiClient.blockUser(
                                widget.authUserId, widget.userId);
                            if (success) {
                              context.read<ChatScreenBloc>().add(
                                    SendMessageEvent(
                                      authUserId: widget.authUserId,
                                      userId: widget.userId,
                                      message: 'You Un blocked this contact.',
                                      type: 'system',
                                      file_url: null,
                                      file_name: '',
                                      ad: null,
                                    ),
                                  );
                              Fluttertoast.showToast(
                                msg: "User Unblocked.",
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
              } else if (state.isYouBlock == false) {
                context.read<MessageInputBloc>().add(ToggleOptionsEvent());
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildMessageTextField(BuildContext context, MessageInputState state) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextField(
                  onTap: () {
                    context.read<MessageInputBloc>().add(SetOptionFalseEvent());
                  },
                  onChanged: (value) {
                    context.read<MessageInputBloc>().add(SetOptionFalseEvent());
                  },
                  controller: messageController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: state is RecordingState && state.isRecording
                        ? 'Recording Voice.....'
                        : localisation(context).typeMessage,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              height: 45,
              width: state is RecordingState && state.isRecording ? 60 : 45,
              margin: const EdgeInsets.only(left: 5, right: 3),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BlocListener<MessageInputBloc, MessageInputState>(
                listener: (context, state) {
                  final isAdTag1 =
                      context.read<MessageInputBloc>().state.isAdTag;
                  if (state is UploadCompleteStateAudio) {
                    context.read<MessageInputBloc>().add(ClearAdTagEvent());
                    context.read<ChatScreenBloc>().add(
                          SendMessageEvent(
                            authUserId: widget.authUserId,
                            userId: widget.userId,
                            message: state.path,
                            type: 'audio',
                            file_url: state.file,
                            file_name: state.message,
                            ad: isAdTag1 ? widget.ad : null,
                          ),
                        );
                  }
                  // context.read<MessageInputBloc>().add(ClearAdTagEvent());
                },
                child: BlocBuilder<ChatScreenBloc, ChatScreenState>(
                  builder: (context, state1) {
                    return GestureDetector(
                      onLongPress: () async {
                        // context
                        //     .read<MessageInputBloc>()
                        //     .add(SetOptionFalseEvent());
                        if (state1.isYouBlock == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text(
                                    'Unblock the user to send message.'),
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
                                      bool success = await apiClient.blockUser(
                                          widget.authUserId, widget.userId);
                                      if (success) {
                                        context.read<ChatScreenBloc>().add(
                                              SendMessageEvent(
                                                authUserId: widget.authUserId,
                                                userId: widget.userId,
                                                message:
                                                    'You Un blocked this contact.',
                                                type: 'system',
                                                file_url: null,
                                                file_name: '',
                                                ad: null,
                                              ),
                                            );
                                        Fluttertoast.showToast(
                                          msg: "User Unblocked.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                              Constants.accentColor,
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
                        } else if (state1.isYouBlock == false) {
                          context
                              .read<MessageInputBloc>()
                              .add(StartRecordingEvent());
                        }
                        // }
                      },
                      onLongPressUp: () {
                        // context
                        //     .read<MessageInputBloc>()
                        //     .add(SetOptionFalseEvent());
                        if (state1.isYouBlock == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const Text(
                                    'Unblock the user to send message.'),
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
                                      bool success = await apiClient.blockUser(
                                          widget.authUserId, widget.userId);
                                      if (success) {
                                        context.read<ChatScreenBloc>().add(
                                              SendMessageEvent(
                                                authUserId: widget.authUserId,
                                                userId: widget.userId,
                                                message:
                                                    'You Un blocked this contact.',
                                                type: 'system',
                                                file_url: null,
                                                file_name: '',
                                                ad: null,
                                              ),
                                            );
                                        Fluttertoast.showToast(
                                          msg: "User Unblocked.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor:
                                              Constants.accentColor,
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
                        } else {
                          context
                              .read<MessageInputBloc>()
                              .add(StopRecordingAndUploadEvent());
                        }
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.mic,
                          size: state is RecordingState && state.isRecording
                              ? 35
                              : 25,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      margin: const EdgeInsets.only(left: 5, right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: BlocBuilder<ChatScreenBloc, ChatScreenState>(
        builder: (context, state) {
          return IconButton(
            color: Colors.amber,
            icon: const Icon(Icons.send),
            onPressed: () {
              context.read<MessageInputBloc>().add(SetOptionFalseEvent());
              if (state.isYouBlock == true) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('Unblock the user to send message.'),
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
                            bool success = await apiClient.blockUser(
                                widget.authUserId, widget.userId);
                            if (success) {
                              context.read<ChatScreenBloc>().add(
                                    SendMessageEvent(
                                      authUserId: widget.authUserId,
                                      userId: widget.userId,
                                      message: 'You Un blocked this contact.',
                                      type: 'system',
                                      file_url: null,
                                      file_name: '',
                                      ad: null,
                                    ),
                                  );
                              Fluttertoast.showToast(
                                msg: "User Unblocked.",
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
              } else if (state.isYouBlock == false) {
                if (messageController.text.isNotEmpty) {
                  final isAdTag1 =
                      context.read<MessageInputBloc>().state.isAdTag;
                  context.read<MessageInputBloc>().add(ClearAdTagEvent());
                  context.read<ChatScreenBloc>().add(SendMessageEvent(
                        authUserId: widget.authUserId,
                        userId: widget.userId,
                        message: messageController.text,
                        type: 'text',
                        file_url: null,
                        file_name: '',
                        ad: isAdTag1 ? widget.ad : null,
                      ));
                  messageController.clear();
                }
              }
            },
          );
        },
      ),
    );
  }
}
