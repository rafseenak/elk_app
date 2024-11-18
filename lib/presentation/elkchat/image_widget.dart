import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
    String newPath = '${directory.path}/images';
    Directory imagesDirectory = Directory(newPath);
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }
    String filePath = '$newPath/${widget.fileName}';
    File newFile = File(filePath);
    final response = await http.get(Uri.parse(widget.imageUrl));
    if (response.statusCode == 200) {
      await newFile.writeAsBytes(response.bodyBytes);
      setState(() {
        isExistFile = true;
        imageFile = newFile;
      });
      return newFile;
    } else {
      throw Exception("Failed to download image: ${response.body}");
    }
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
