// ignore_for_file: avoid_print

import 'dart:io';
import 'package:elk/presentation/elkchat/gallary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:bloc/bloc.dart';
import 'message_input_event.dart';
import 'message_input_state.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class MessageInputBloc extends Bloc<MessageInputEvent, MessageInputState> {
  final ImagePicker _picker = ImagePicker();
  bool showOptions = false;
  double mainContainerHeight = 48;
  bool isRecording = false;
  bool isRecorderOpen = false;
  final bool isAdTag;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final GlobalKey<NavigatorState> navigatorKey;
  MessageInputBloc(this.navigatorKey, {required this.isAdTag})
      : super(MessageInputInitial(isAdTag)) {
    _initializeRecorder();
    on<ToggleOptionsEvent>((event, emit) {
      showOptions = !showOptions;
      mainContainerHeight = showOptions ? 142 : 48;
      emit(
          OptionsToggledState(showOptions, mainContainerHeight, state.isAdTag));
    });

    on<SetOptionFalseEvent>((event, emit) {
      showOptions = false;
      mainContainerHeight = showOptions ? 142 : 48;
      emit(
          OptionsToggledState(showOptions, mainContainerHeight, state.isAdTag));
    });

    on<StartRecordingEvent>((event, emit) async {
      _resetOptions();
      if (await Permission.microphone.request().isGranted) {
        if (isRecorderOpen && !isRecording) {
          isRecording = true;
          await _recorder.startRecorder(toFile: 'voice_message.aac');
          emit(RecordingState(isRecording, state.isAdTag));
        }
      }
    });

    on<ClearAdTagEvent>((event, emit) async {
      emit(MessageInputInitial(false));
    });

    on<StopRecordingAndUploadEvent>((event, emit) async {
      _resetOptions();
      if (isRecording) {
        try {
          String? path = await _recorder.stopRecorder();
          isRecording = false;
          emit(RecordingState(isRecording, state.isAdTag));
          if (path != null) {
            final directory = await getDownloadsDirectory();
            final directoryPath = directory?.path;
            if (directoryPath != null) {
              final now = DateTime.now();
              final uuid = const Uuid().v4();
              final extension = path.split('.').last;
              String uniqueFileName =
                  '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}_$uuid.$extension';
              String newPath = '$directoryPath/voiceMessages/$uniqueFileName';
              final newFileDirectory = Directory(newPath).parent;
              if (!await newFileDirectory.exists()) {
                await newFileDirectory.create(recursive: true);
              }
              File recordedFile = File(path);
              await recordedFile.copy(newPath);
              await recordedFile.delete();
              emit(UploadCompleteStateAudio(newPath, uniqueFileName,
                  File(newPath), newPath, state.isAdTag));
            }
          }
        } catch (e) {
          emit(UploadFailedState(e.toString(), state.isAdTag));
        }
      }
    });

    on<SetMessageEvent>((event, emit) async {
      emit(MessageState(event.message, state.isAdTag));
    });

    on<PickFileEvent>(_onPickFileEvent);

    on<OpenCameraEvent>(_onOpenCameraEvent);
  }

  Future<void> _initializeRecorder() async {
    if (!isRecorderOpen) {
      await _recorder.openRecorder();
      isRecorderOpen = true;
    }
  }

  Future<void> _onPickFileEvent(
      PickFileEvent event, Emitter<MessageInputState> emit) async {
    final XFile? media;
    if (event.isVideo) {
      media = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      media = await _picker.pickImage(source: ImageSource.gallery);
    }
    if (media != null) {
      final selectedFile = await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => CustomGalleryPicker(media: media),
        ),
      );

      if (selectedFile != null) {
        final directory = await getDownloadsDirectory();
        final directoryPath = directory?.path;
        emit(UploadInProgressState(state.isAdTag));
        if (directoryPath != null) {
          final now = DateTime.now();
          final uuid = const Uuid().v4();
          final extension = selectedFile.path.split('.').last;
          String uniqueFileName =
              '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}_$uuid.$extension';
          String newPath = event.isVideo
              ? '$directoryPath/videos/$uniqueFileName'
              : '$directoryPath/images/$uniqueFileName';
          final newFileDirectory = Directory(newPath).parent;
          if (!await newFileDirectory.exists()) {
            await newFileDirectory.create(recursive: true);
          }

          try {
            File newFile = File(selectedFile.path);
            if (event.isVideo) {
              await newFile.copy(newPath);
              await newFile.delete();
              emit(UploadCompleteStateVideo(newPath, uniqueFileName,
                  File(newPath), newPath, state.isAdTag));
            } else {
              XFile? compressedFile = await compressFile(newFile, newPath);
              File myFile = File(compressedFile!.path);
              print('Success: ${myFile.path}');
              emit(UploadCompleteStateImage(newPath, uniqueFileName,
                  File(newPath), newPath, state.isAdTag));
            }
          } catch (e) {
            print("Error copying file: $e");
          }
        }
      }
    }
  }

  Future<void> _onOpenCameraEvent(
      OpenCameraEvent event, Emitter<MessageInputState> emit) async {
    final XFile? media = await _picker.pickImage(source: ImageSource.camera);
    if (media != null) {
      final selectedFile = await navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => CustomGalleryPicker(media: media),
        ),
      );

      if (selectedFile != null) {
        final directory = await getDownloadsDirectory();
        final directoryPath = directory?.path;
        emit(UploadInProgressState(state.isAdTag));
        if (directoryPath != null) {
          final now = DateTime.now();
          final uuid = const Uuid().v4();
          final extension = selectedFile.path.split('.').last;
          String uniqueFileName =
              '${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}_$uuid.$extension';
          String newPath = '$directoryPath/images/$uniqueFileName';
          final newFileDirectory = Directory(newPath).parent;
          if (!await newFileDirectory.exists()) {
            await newFileDirectory.create(recursive: true);
          }
          try {
            File newFile = File(selectedFile.path);
            XFile? compressedFile = await compressFile(newFile, newPath);
            File myFile = File(compressedFile!.path);
            print('Success: ${myFile.path}');
            emit(UploadCompleteStateCamera(newPath, uniqueFileName,
                File(newPath), newPath, state.isAdTag));
            await newFile.delete();
          } catch (e) {
            print("Error copying file: $e");
          }
        }
      }
    }
  }

  Future<XFile?> compressFile(File file, String targetPath) async {
    final int fileSize = await file.length();

    if (fileSize <= 500 * 1024) {
      return XFile(file.path);
    }
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
      rotate: 180,
    );
    return result;
  }

  void _resetOptions() {
    showOptions = false;
    mainContainerHeight = 48;
  }

  @override
  Future<void> close() async {
    if (isRecorderOpen) {
      await _recorder.closeRecorder();
      isRecorderOpen = false;
    }
    return super.close();
  }
}
