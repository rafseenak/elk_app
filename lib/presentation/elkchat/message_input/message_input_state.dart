import 'dart:io';

abstract class MessageInputState {
  final bool isAdTag;
  MessageInputState(this.isAdTag);
}

class MessageInputInitial extends MessageInputState {
  MessageInputInitial(super.isAdTag);
}

class OptionsToggledState extends MessageInputState {
  final bool showOptions;
  final double containerHeight;

  OptionsToggledState(this.showOptions, this.containerHeight, super.isAdTag);
}

class RecordingState extends MessageInputState {
  final bool isRecording;

  RecordingState(this.isRecording, super.isAdTag);
}

class MessageState extends MessageInputState {
  final String message;

  MessageState(this.message, super.isAdTag);
}

class UploadInProgressState extends MessageInputState {
  UploadInProgressState(super.isAdTag);
}

class UploadCompleteStateAudio extends MessageInputState {
  final String downloadUrl;
  final String message;
  final File file;
  final String path;
  UploadCompleteStateAudio(
      this.downloadUrl, this.message, this.file, this.path, super.isAdTag);
}

class UploadCompleteStateImage extends MessageInputState {
  final String downloadUrl;
  final String message;
  final File file;
  final String path;
  UploadCompleteStateImage(
      this.downloadUrl, this.message, this.file, this.path, super.isAdTag);
}

class UploadCompleteStateVideo extends MessageInputState {
  final String downloadUrl;
  final String message;
  final File file;
  final String path;
  UploadCompleteStateVideo(
      this.downloadUrl, this.message, this.file, this.path, super.isAdTag);
}

class UploadCompleteStateCamera extends MessageInputState {
  final String downloadUrl;
  final String message;
  final File file;
  final String path;
  UploadCompleteStateCamera(
      this.downloadUrl, this.message, this.file, this.path, super.isAdTag);
}

class UploadFailedState extends MessageInputState {
  final String error;
  UploadFailedState(this.error, super.isAdTag);
}

// class FilePickedState extends MessageInputState {
//   final String filePath;
//   final String fileType;

//   FilePickedState(this.filePath, this.fileType, super.isAdTag);
// }
