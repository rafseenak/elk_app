import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:square_progress_bar/square_progress_bar.dart';

class AdPostStage2Screen extends StatefulWidget {
  final String categoryTitle;
  final AdPostCubit adPostCubit;
  const AdPostStage2Screen(
    this.categoryTitle,
    this.adPostCubit, {
    super.key,
  });

  @override
  State<AdPostStage2Screen> createState() {
    return _AdPostStage2Body();
  }
}

class _AdPostStage2Body extends State<AdPostStage2Screen> {
  late final AdPostCubit adPostCubit = widget.adPostCubit;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        child: Column(children: [
          defualutUploadBox(),
          uploadButtons(),
          ValueListenableBuilder(
              valueListenable: adPostCubit.imagesNotifer,
              builder: (context, images, child) {
                return Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: imagesgrid(images),
                ));
              }),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
                width: double.infinity, height: 40, child: nextButton()),
          )
        ]),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(localisation(context).photos),
          /* Text(
            '${widget.categoryTitle} ${localisation(context).photoDetials}',
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .copyWith(fontSize: 12),
          ) */
        ],
      ),
      elevation: 1,
    );
  }

  Widget defualutUploadBox() {
    return ValueListenableBuilder<double>(
        valueListenable: adPostCubit.imageProgressNotifer,
        builder: (context, progress, child) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SquareProgressBar(
              strokeWidth: 2,
              barStrokeCap: StrokeCap.round,
              width: double.infinity,
              height: 130,
              gradientBarColor: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomLeft,
                  colors: [Colors.green, Colors.greenAccent]),
              progress: progress,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(children: [
                  Text(
                    localisation(context).uploadPhotos,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 17, height: 1.5),
                  ),
                  Text(
                    localisation(context).youCanUpload,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  if (progress != 0.0) const Text('Uploading')
                ]),
              ),
            ),
          );
        });
  }

  Widget uploadButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        FilledButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.all(
                  const Color.fromARGB(66, 71, 71, 71)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            onPressed: () async {
              await pickMultiImage().then((value) async {
                adPostCubit.updateMultiImages('local', value);
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.photo_sharp,
                  color: Color(0xFF4Fbbb4),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    localisation(context).gallery,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: const Color(0xFF4Fbbb4)),
                  ),
                )
              ],
            )),
        FilledButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.all(
                  const Color.fromARGB(66, 71, 71, 71)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            onPressed: () async {
              await takeCamer().then((value) async {
                debugPrint(value.toString());
                if (value != null) {
                  adPostCubit.updateImaegStream('local', value);
                }
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF4Fbbb4),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    localisation(context).camera,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: const Color(0xFF4Fbbb4)),
                  ),
                )
              ],
            )),
      ]),
    );
  }

  Widget imagesgrid(List<Map<String, dynamic>> images) {
    return GridView.builder(
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 20),
        itemBuilder: (context, index) {
          bool isLoading = false;
          return StatefulBuilder(builder: (context, statefulState) {
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: images[index]['type'] == 'local'
                      ? Image.file(
                          File(
                            images[index]['path'],
                          ),
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        )
                      : CachedNetworkImage(
                          imageUrl: images[index]['path'],
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                        ),
                ),
                Positioned(
                    right: 0,
                    bottom: 20,
                    child: IconButton(
                      iconSize: 35,
                      onPressed: () async {
                        if (images[index]['type'] == 'local') {
                          adPostCubit.deleteImage(
                              'local', images[index]['path']);
                        } else {
                          statefulState(() {
                            isLoading = true;
                          });
                          await adPostCubit
                              .deleteAdImage(images[index]['id'])
                              .then((value) {
                            if (value.success) {
                              Fluttertoast.showToast(msg: 'Image removed');
                              adPostCubit.deleteImage(
                                  'network', images[index]['path']);
                            } else {
                              Fluttertoast.showToast(
                                  msg: value.message.toString());
                            }
                            if (mounted) {
                              statefulState(() {
                                isLoading = false;
                              });
                            }
                          });
                        }
                      },
                      icon: ClipOval(
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration:
                                  const BoxDecoration(color: Colors.red),
                              child: !isLoading
                                  ? const Icon(
                                      Icons.delete,
                                      size: 15,
                                      color: Colors.white,
                                    )
                                  : const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.white,
                                      )),
                                    ))),
                    ))
              ],
            );
          });
        });
  }

  Widget nextButton() {
    return FilledButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.amber),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        onPressed: () async {
          if (widget.adPostCubit.imagesNotifer.value.isEmpty) {
            Fluttertoast.showToast(msg: 'Please add some images');
          } else {
            isLoading.value = true;
            await adPostCubit.uploadAdImage().then((value) {
              if (value.success) {
                Navigator.pushNamed(context, RouteConstants.adPostStage3,
                    arguments: {
                      'categoryTitle': widget.categoryTitle,
                      'adPostCubit': widget.adPostCubit
                    });
              } else {
                Fluttertoast.showToast(msg: value.message.toString());
              }
              isLoading.value = false;
            });
          }
        },
        child: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, loadin, chil) {
              return !loadin
                  ? Text(localisation(context).next)
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    );
            }));
  }
}
