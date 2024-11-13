abstract class MessageInputEvent {}

class ToggleOptionsEvent extends MessageInputEvent {}

class SetOptionFalseEvent extends MessageInputEvent {}

class StartRecordingEvent extends MessageInputEvent {}

class StopRecordingAndUploadEvent extends MessageInputEvent {}

class SetMessageEvent extends MessageInputEvent {
  final String message;

  SetMessageEvent(this.message);
}

class SendVoiceMessageEvent extends MessageInputEvent {}

class PickFileEvent extends MessageInputEvent {
  final bool isVideo;

  PickFileEvent(this.isVideo);
}

class OpenCameraEvent extends MessageInputEvent {}

class ClearAdTagEvent extends MessageInputEvent {}
