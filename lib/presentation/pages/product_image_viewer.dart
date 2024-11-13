// ignore_for_file: unused_import, unnecessary_import, must_be_immutable, prefer_final_fields, unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProductImageViewer extends StatefulWidget {
  int index;
  final List<String> images;
  ProductImageViewer(this.index, this.images, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProductImageViewerState();
  }
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late final _scrollController = PageController(initialPage: widget.index);
  double _scale = 1.0;
  double _previousScale = 1.0;
  bool pageEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
              physics: pageEnabled
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: _scrollController,
              children: List.generate(
                  widget.images.length,
                  (index) => Hero(
                        tag: index,
                        child: EasyImageView(
                          doubleTapZoomable: true,
                          onScaleChanged: (scale) {
                            setState(() {
                              pageEnabled = scale <= 1.0;
                            });
                          },
                          imageProvider:
                              CachedNetworkImageProvider(widget.images[index]),
                        ),
                      ))),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CloseButton(
                style: const ButtonStyle(
                    iconColor: MaterialStatePropertyAll(Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
