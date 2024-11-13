import 'dart:io';
import 'package:elk/presentation/chat/widgets/video_message.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomGalleryPicker extends StatefulWidget {
  final XFile? media;
  const CustomGalleryPicker({
    super.key,
    required this.media,
  });

  @override
  State<CustomGalleryPicker> createState() => _CustomGalleryPickerState();
}

class _CustomGalleryPickerState extends State<CustomGalleryPicker> {
  XFile? _pickedFile;
  CroppedFile? _croppedFile;
  void _selectMedia() {
    if (_pickedFile != null) {}
    Navigator.pop(context, _pickedFile);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.media != null) {
        _pickedFile = widget.media;
      }
    });
  }

  Widget _imageCard() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: _image(),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(
              top: 70,
            ),
            child: _menu(),
          ),
        ),
      ],
    );
  }

  Widget _image() {
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return Image.file(File(path));
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 350,
        ),
        child: Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isVideo() {
    if (_pickedFile != null) {
      return _pickedFile!.path.endsWith('.mp4') ||
          _pickedFile!.path.endsWith('.mov') ||
          _pickedFile!.path.endsWith('.mkv');
    }
    return false;
  }

  bool isImage() {
    if (_pickedFile != null) {
      return _pickedFile!.path.endsWith('.jpg') ||
          _pickedFile!.path.endsWith('.jpeg') ||
          _pickedFile!.path.endsWith('.png') ||
          _pickedFile!.path.endsWith('.gif');
    }
    return false;
  }

  Widget _menu() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            backgroundColor: Colors.transparent,
            tooltip: 'Crop',
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ),
        if (isImage())
          Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              onPressed: () {
                _cropImage();
              },
              backgroundColor: Colors.transparent,
              tooltip: 'Crop',
              child: const Icon(
                Icons.crop_free,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '',
            toolbarColor: const Color.fromARGB(255, 0, 0, 0),
            toolbarWidgetColor: const Color.fromARGB(255, 255, 255, 255),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
            showCropGrid: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
            ],
          ),
          IOSUiSettings(
            title: 'Cropper',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
            ],
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 520,
              height: 520,
            ),
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          isVideo()
              ? VideoMessageWidget(videoPath: _pickedFile!.path)
              : isImage()
                  ? _imageCard()
                  : const Text("File Does not Support"),
          if (isVideo() || isImage())
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 45,
                width: 45,
                margin: const EdgeInsets.only(right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_croppedFile != null) {
                      _pickedFile = XFile(_croppedFile!.path);
                    }
                    _selectMedia();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
