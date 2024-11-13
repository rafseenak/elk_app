import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ImageMessageBubble extends StatefulWidget {
  final String imageUrl;
  final String fileName;
  final String appDirectory;

  const ImageMessageBubble({
    super.key,
    required this.imageUrl,
    required this.fileName,
    required this.appDirectory,
  });

  @override
  State<ImageMessageBubble> createState() => _ImageMessageBubbleState();
}

class _ImageMessageBubbleState extends State<ImageMessageBubble> {
  File? imageFile;
  bool isDownloading = false;
  bool isExistFile = false;

  @override
  void initState() {
    super.initState();
    setImageFileExist();
  }

  Future<void> setImageFileExist() async {
    final filePath = widget.appDirectory;
    final file = File(filePath);
    if (await file.exists()) {
      setState(() {
        isExistFile = true;
        imageFile = file;
      });
    } else {
      setState(() {
        isExistFile = false;
      });
    }
  }

  Future<File> downloadImage() async {
    Directory? directory = await getDownloadsDirectory();
    directory ??= await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception("No available directory to download the file.");
    }
    String newPath = '${directory.path}/${widget.fileName}';
    Reference storageRef = FirebaseStorage.instance.refFromURL(widget.imageUrl);
    File newFile = File(newPath);
    await storageRef.writeToFile(newFile);
    setState(() {
      isExistFile = true;
      imageFile = newFile;
    });
    return newFile;
  }

  @override
  Widget build(BuildContext context) {
    return isExistFile && imageFile != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(imageFile!),
          )
        : Stack(
            children: [
              Image.asset(
                'assets/images/chat_blur_image.jpg',
                fit: BoxFit.cover,
              ),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8.0),
              //   child: CachedNetworkImage(
              //     fit: BoxFit.cover,
              //     imageUrl: widget.imageUrl,
              //   ).blurred(blur: 5.0),
              // ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Center(
                  child: isDownloading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            if (isDownloading) return;
                            setState(
                              () {
                                isDownloading = true;
                              },
                            );
                            try {
                              await downloadImage();
                              await setImageFileExist();
                            } finally {
                              setState(
                                () {
                                  isDownloading = false;
                                },
                              );
                            }
                          },
                        ),
                ),
              ),
            ],
          );
  }
}
