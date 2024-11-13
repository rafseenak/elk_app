// ignore_for_file: empty_catches, use_build_context_synchronously

import 'dart:io';
import 'package:elk/constants.dart';
import 'package:elk/presentation/chat/chat_service.dart';
import 'package:elk/presentation/chat/gallary.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MessageInputWidget extends StatefulWidget {
  final int? userId;
  final int? authUserId;
  final Map<String, dynamic> ad;

  final Map<String, Map<String, dynamic>?> userDetails;
  const MessageInputWidget({
    super.key,
    required this.userId,
    required this.authUserId,
    required this.userDetails,
    required this.ad,
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget> {
  bool showOptions = false;
  double mainContainerHeight = 48;
  bool isRecording = false;
  bool isAdTag = false;
  FlutterSoundRecorder? _recorder;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();
  @override
  void initState() {
    super.initState();
    setState(() {
      showOptions = false;
    });
    if (widget.ad.isNotEmpty) {
      setState(() {
        isAdTag = true;
      });
    }
    _recorder = FlutterSoundRecorder();
    _recorder!.openRecorder();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<File> compressImage(File file) async {
    final compressedImage = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80,
    );
    final newFile = File(file.path)..writeAsBytesSync(compressedImage!);
    return newFile;
  }

  void storeMessageInDb() {}

  void _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() {
        isRecording = true;
      });
      await _recorder!.startRecorder(toFile: 'voice_message.aac');
    }
  }

  String _generateUniqueFilename(String originalPath) {
    final now = DateTime.now();
    final uuid = const Uuid().v4();
    final extension = originalPath.split('.').last;

    return '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}_$uuid.$extension';
  }

  void _stopRecording() async {
    String? path = await _recorder!.stopRecorder();
    String downloadUrl = '';
    setState(() {
      isRecording = false;
    });
    if (path != null) {
      final directory = await getDownloadsDirectory();
      final directoryPath = directory?.path;
      if (directoryPath != null) {
        final directory = Directory(directoryPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        String uniqueFileName = _generateUniqueFilename(path);
        String newPath = '$directoryPath/$uniqueFileName';
        File recordedFile = File(path);

        await recordedFile.copy(newPath);
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('elkfiles/voicemessages/$uniqueFileName');
          UploadTask uploadTask = ref.putFile(File(newPath));
          await uploadTask.whenComplete(() => null);
          downloadUrl = await ref.getDownloadURL();
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});
        } catch (e) {}

        await recordedFile.delete();
        _sendVoiceMessage(newPath, uniqueFileName, downloadUrl);
      }
    }
  }

  void _sendVoiceMessage(
      String audioPath, String onlinePath, String url) async {
    Map<String, dynamic> adData;
    if (isAdTag) {
      adData = widget.ad;
    } else {
      adData = {};
    }
    setState(() {
      isAdTag = false;
    });
    if (audioPath.isNotEmpty) {
      await _chatService.sendMessage(audioPath, 'audio', onlinePath, url,
          widget.userId, widget.authUserId, widget.userDetails, adData);
      storeMessageInDb();
    }
  }

  void sendMessage() async {
    Map<String, dynamic> adData;
    if (isAdTag) {
      adData = widget.ad;
    } else {
      adData = {};
    }
    setState(() {
      isAdTag = false;
    });
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(_messageController.text, 'text', '', "",
          widget.userId, widget.authUserId, widget.userDetails, adData);
      storeMessageInDb();
    }
    _messageController.clear();
  }

  void _pickFile({required bool isVideo}) async {
    final XFile? media;
    if (isVideo) {
      media = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      media = await _picker.pickImage(source: ImageSource.gallery);
    }
    if (media != null) {
      final selectedFile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomGalleryPicker(
            media: media,
          ),
        ),
      );
      if (selectedFile != null) {
        await _storeFile(selectedFile.path);
      }
    }
  }

  Future<void> _openCamera() async {
    final XFile? media = await _picker.pickImage(source: ImageSource.camera);
    final selectedFile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomGalleryPicker(
          media: media,
        ),
      ),
    );
    if (selectedFile != null) {
      await _storeFile(selectedFile.path);
    }
  }

  Future<String> _storeFile(String filePath) async {
    final directory = await getDownloadsDirectory();
    final directoryPath = directory?.path;
    String downloadUrl = '';
    if (directoryPath != null) {
      final file = File(filePath);
      final uniqueFileName = _generateUniqueFilename(filePath);
      final newFilePath = '$directoryPath/$uniqueFileName';

      await file.copy(newFilePath);
      String fileType = _getFileType(filePath.split('.').last);
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('elkfiles/images/$uniqueFileName');

        UploadTask uploadTask = ref.putFile(File(newFilePath));
        await uploadTask.whenComplete(() => null);
        downloadUrl = await ref.getDownloadURL();
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});
        _sendFileMessage(newFilePath, fileType, uniqueFileName, downloadUrl);
      } catch (e) {}
      return newFilePath;
    }
    throw Exception('Error');
  }

  void _sendFileMessage(String filePath, String fileType, String fileName,
      String downloadUrl) async {
    Map<String, dynamic> adData;
    if (isAdTag) {
      adData = widget.ad;
    } else {
      adData = {};
    }
    setState(() {
      isAdTag = false;
    });
    if (filePath.isNotEmpty) {
      await _chatService.sendMessage(filePath, fileType, fileName, downloadUrl,
          widget.userId, widget.authUserId, widget.userDetails, adData);
      storeMessageInDb();
    }
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'mp4':
      case 'mov':
        return 'video';
      default:
        return 'file';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: mainContainerHeight,
              margin: const EdgeInsets.only(left: 15, right: 4, bottom: 15),
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(35)),
                color: Colors.amber,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showOptions)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOptionButton(
                            icon: Icons.camera_outlined,
                            onPressed: () {
                              _openCamera();
                            },
                          ),
                          _buildOptionButton(
                            icon: Icons.image_outlined,
                            onPressed: () {
                              _pickFile(isVideo: false);
                            },
                          ),
                          _buildOptionButton(
                            icon: Icons.videocam_outlined,
                            onPressed: () {
                              _pickFile(isVideo: true);
                            },
                          ),
                        ],
                      ),
                    ),
                  _buildToggleOptionsButton(),
                ],
              ),
            ),
            _buildMessageTextField(),
            _buildMicButton(),
          ],
        ),
      ],
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

  Widget _buildToggleOptionsButton() {
    return Container(
      margin: const EdgeInsets.all(2),
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: IconButton(
        icon: Icon(showOptions ? Icons.close : Icons.add),
        onPressed: () {
          setState(() {
            showOptions = !showOptions;
            if (mainContainerHeight == 182) {
              mainContainerHeight = 48;
            } else {
              mainContainerHeight = 182;
            }
          });
        },
      ),
    );
  }

  Widget _buildMessageTextField() {
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
                padding: const EdgeInsets.only(left: 5),
                child: TextField(
                  style: const TextStyle(fontSize: 14),
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: isRecording
                        ? 'Recording Voice.....'
                        : localisation(context).typeMessage,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Container(
              height: 45,
              width: isRecording ? 60 : 45,
              margin: const EdgeInsets.only(left: 5, right: 3),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                // onTap: isRecording ? _stopRecording : _startRecording,
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mic,
                    size: isRecording ? 35 : 25,
                    color: Colors.white,
                  ),
                ),
              ),
              // child: IconButton(
              //   color: Constants.primaryColor,
              //   icon: const Icon(Icons.send),
              //   onPressed: () {
              //     sendMessage();
              //   },
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return Container(
      height: 50,
      width: 50,
      margin: const EdgeInsets.only(left: 5, right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        color: Constants.primaryColor,
        icon: const Icon(Icons.send),
        onPressed: () {
          sendMessage();
        },
      ),
    );
    // return Container(
    //   width: isRecording ? 70 : 50,
    //   height: isRecording ? 70 : 50,
    //   margin: const EdgeInsets.only(left: 5, right: 15, bottom: 15),
    //   padding: const EdgeInsets.all(3),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(15),
    //     color: isRecording ? Colors.amber : Colors.white,
    //   ),
    //   child: Align(
    //     alignment: Alignment.center,
    //     child: IconButton(
    //       iconSize: 25,
    //       color: isRecording ? Colors.white : Colors.black,
    //       icon: const Icon(Icons.mic),
    //       onPressed: isRecording ? _stopRecording : _startRecording,
    //     ),
    //   ),
    // );
  }
}
