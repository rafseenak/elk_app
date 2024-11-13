import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class AudioMessageBubble extends StatefulWidget {
  final String appDirectory;
  final String audioUrl;
  final String fileName;
  const AudioMessageBubble({
    super.key,
    required this.appDirectory,
    required this.audioUrl,
    required this.fileName,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  File? file;
  bool isDownloading = false;
  bool isExistFile = false;
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Color.fromARGB(255, 129, 120, 120),
    liveWaveColor: Color.fromARGB(255, 0, 0, 0),
    spacing: 3,
    waveThickness: 2,
    waveCap: StrokeCap.round,
  );

  @override
  void initState() {
    super.initState();
    file = File(widget.appDirectory);
    controller = PlayerController();
    setFileExist();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((_) {
      setState(() {});
    });
  }

  Future<void> setFileExist() async {
    final filePath = widget.appDirectory;
    final file = File(filePath);
    if (await file.exists()) {
      setState(() {
        isExistFile = true;
        this.file = file;
      });
    } else {
      setState(() {
        isExistFile = false;
      });
    }
  }

  void _preparePlayer() async {
    try {
      await controller.preparePlayer(
        path: file!.path,
        shouldExtractWaveform: false,
      );
      await controller.extractWaveformData(
        path: file!.path,
        noOfSamples: playerWaveStyle.getSamplesForWidth(120),
      );
    } catch (e) {
      debugPrint('Error downloading or preparing the player: $e');
    }
  }

  Future<File> dowloadAudio() async {
    Directory? directory = await getDownloadsDirectory();

    directory ??= await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception("No available directory to download the file.");
    }
    String newPath = '${directory.path}/${widget.fileName}';
    Reference storageRef = FirebaseStorage.instance.refFromURL(widget.audioUrl);
    File newfile = File(newPath);
    await storageRef.writeToFile(newfile);
    setState(() {
      isExistFile = true;
      file = newfile;
    });
    _preparePlayer();
    return newfile;
  }

  Future<File> downloadAudioFromS3() async {
    Directory? directory = await getDownloadsDirectory();
    directory ??= await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception("No available directory to download the file.");
    }
    String newPath = '${directory.path}/voiceMessages/${widget.fileName}';
    File newfile = File(newPath);
    final response = await http.get(Uri.parse(widget.audioUrl));

    if (response.statusCode == 200) {
      await newfile.writeAsBytes(response.bodyBytes);
      setState(() {
        isExistFile = true;
        file = newfile;
      });
      _preparePlayer();
      return newfile;
    } else {
      throw Exception("Failed to download audio: ${response.body}");
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return file != null
        ? Row(
            children: [
              IconButton(
                onPressed: () async {
                  if (isDownloading) return;

                  if (!isExistFile) {
                    setState(() {
                      isDownloading = true;
                    });
                    try {
                      await downloadAudioFromS3();
                      await setFileExist();
                    } finally {
                      setState(() {
                        isDownloading = false;
                      });
                    }
                  } else {
                    if (controller.playerState.isPlaying) {
                      await controller.pausePlayer();
                    } else {
                      await controller.startPlayer(
                          finishMode: FinishMode.pause);
                    }
                  }
                },
                icon: isDownloading
                    ? const CircularProgressIndicator()
                    : Icon(
                        size: 40,
                        !isExistFile
                            ? Icons.download
                            : controller.playerState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                      ),
                color: const Color.fromARGB(255, 129, 120, 120),
              ),
              AudioFileWaveforms(
                size: const Size(120, 50),
                playerController: controller,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: playerWaveStyle,
              ),
            ],
          )
        : Row(
            children: [
              IconButton(
                onPressed: () async {},
                icon: const Icon(Icons.play_arrow),
                color: const Color.fromARGB(255, 129, 120, 120),
              ),
              AudioFileWaveforms(
                size: const Size(120, 50),
                playerController: controller,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: playerWaveStyle,
              ),
            ],
          );
  }
}
