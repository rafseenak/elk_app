// ignore_for_file: unused_import, unnecessary_import, depend_on_referenced_packages, avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/widgets/map_widget.dart';
import 'package:elk/shared/contact_dialog_widget.dart';
import 'package:elk/shared/loading_dialog.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RentItemScreen extends StatefulWidget {
  final int adId;
  const RentItemScreen({super.key, required this.adId});

  @override
  State<RentItemScreen> createState() {
    return _RentItemScreenBody();
  }
}

class _RentItemScreenBody extends State<RentItemScreen> {
  final _wishListNotifer = ValueNotifier<bool>(false);
  final requireUpdate = ValueNotifier(false);
  bool canPop = true;
  Map<String, dynamic> adDetails = {};
  final PageController _pageController = PageController();
  Future<DataSet<AdResponse?>>? future;
  late final rentAdsRepository =
      RepositoryProvider.of<RentAdsRepository>(context);

  @override
  void initState() {
    super.initState();
    future = rentAdsRepository.getAdDetails(widget.adId);
  }

  Future<void> shareAd(String title, String description, String image) async {
    loadingDialog(context, dismisaable: true);
    final response = await http.get(Uri.parse(image));
    final direcory = await getTemporaryDirectory();
    final imagePath = path.join(direcory.path, 'cached_image.jpg');
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(response.bodyBytes);

    await Share.shareXFiles([
      XFile(imageFile.path)
    ], text: '''Title : $title\n Description: ${description.substring(0, description.length > 40 ? 40 : description.length)}...\n Check now : https://elkcompany.in/ad/${widget.adId}''')
        .then((value) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = 200;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.pop(context, requireUpdate.value);
      },
      child: Scaffold(
        body: FutureBuilder(
            future: future,
            builder: (context, snapShot) => customScrollView(
                context, rentAdsRepository, width, height, snapShot)),
      ),
    );
  }

  Widget customScrollView(
      BuildContext context,
      RentAdsRepository rentAdsRepository,
      double width,
      double height,
      AsyncSnapshot<DataSet<AdResponse?>> snapShot) {
    if (snapShot.connectionState == ConnectionState.done &&
        (!snapShot.data!.success || snapShot.data!.data == null)) {
      return const Center(child: Text('Somethink went wrong'));
    }
    final adResponse = snapShot.data;
    if (snapShot.hasData && adResponse != null) {
      adDetails = {
        'adName': adResponse.data!.title,
        'adId': adResponse.data!.adId,
      };
    }

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                _imageSlider(rentAdsRepository, snapShot),
                _header(context, rentAdsRepository, snapShot),
                const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider()),
                _description(snapShot),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: adIdandDate(context, snapShot),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: snapShot.connectionState == ConnectionState.waiting
                      ? Shimmer.fromColors(
                          baseColor: Theme.of(context).canvasColor,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            color: Theme.of(context).canvasColor,
                            width: width,
                            height: height,
                          ),
                        )
                      : Gmap(
                          width: width,
                          height: height,
                          latitude: double.parse(
                              snapShot.data!.data!.adLocation!.latitude),
                          longitude: double.parse(
                              snapShot.data!.data!.adLocation!.longitude)),
                ),
              ])),
            ],
          ),
        ),
        buttons(context, snapShot)
      ],
    );
  }

  Widget _imageSlider(RentAdsRepository rentAdsRepository,
          AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
      Builder(builder: (context) {
        return Stack(
          children: [
            SizedBox(
              height: 250,
              child: snapShot.connectionState == ConnectionState.waiting
                  ? Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.shade300,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 250,
                      ),
                    )
                  : Builder(builder: (context) {
                      final list = snapShot.data!.data!.adImages;
                      return Stack(
                        children: [
                          PageView.builder(
                              controller: _pageController,
                              allowImplicitScrolling: true,
                              itemCount: list.length,
                              itemBuilder: ((context, index) => GestureDetector(
                                    onTap: () {
                                      /* final imageProvider = MultiImageProvider(
                                          list
                                              .map((e) =>
                                                  CachedNetworkImageProvider(
                                                      e.image))
                                              .toList());
                                      showImageViewerPager(
                                        doubleTapZoomable: true,
                                          context, imageProvider); */
                                      Navigator.pushNamed(context,
                                          RouteConstants.productImageViewer,
                                          arguments: {
                                            'index': index,
                                            'images': list
                                                .map((e) => e.image)
                                                .toList()
                                          });
                                    },
                                    child: Hero(
                                      tag: index,
                                      child: CachedNetworkImage(
                                        useOldImageOnUrlChange: true,
                                        fadeInDuration:
                                            const Duration(milliseconds: 100),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 100),
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.grey.shade50,
                                        ),
                                        imageUrl: list[index].image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ))),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)),
                              child: SmoothPageIndicator(
                                  effect: const WormEffect(
                                      activeDotColor: Color(0xFF4Fbbb4),
                                      dotHeight: 5,
                                      dotWidth: 5),
                                  controller: _pageController,
                                  count: list.length),
                            ),
                          )
                        ],
                      );
                    }),
            ),
            snapShot.connectionState == ConnectionState.done
                ? Positioned(
                    left: 20,
                    top: 30,
                    child: ClipOval(
                        child: SizedBox(
                      width: 35,
                      height: 35,
                      child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.white),
                          child: BackButton(
                            style: const ButtonStyle(
                                padding:
                                    MaterialStatePropertyAll(EdgeInsets.all(0)),
                                iconSize: MaterialStatePropertyAll(18)),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.of(context).pop(requireUpdate.value);
                            },
                          )),
                    )),
                  )
                : const SizedBox()
          ],
        );
      });

  Widget _header(BuildContext context, RentAdsRepository rentAdsRepository,
          AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
      Builder(builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  snapShot.connectionState == ConnectionState.waiting
                      ? Shimmer.fromColors(
                          baseColor: Colors.white,
                          highlightColor: Colors.grey.shade300,
                          child: Container(
                            width: 150,
                            height: 15,
                            color: Colors.white,
                          ))
                      : Builder(builder: (context) {
                          final title = snapShot.data!.data!.title;
                          return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 250,
                                child: SelectableText(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        shareAd(
                                            title,
                                            snapShot.data!.data!.description,
                                            snapShot.data!.data!.adImages.first
                                                .image);
                                      },
                                      child: const Icon(
                                        Icons.share,
                                        color: Constants.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Builder(builder: (context) {
                                    bool whishListed =
                                        snapShot.data!.data!.wishListed ??
                                            false;
                                    return StatefulBuilder(
                                        builder: (context, statefulState) {
                                      return ValueListenableBuilder<bool>(
                                          valueListenable: _wishListNotifer,
                                          builder: (context, loading, child) {
                                            return GestureDetector(
                                              onTap: () async {
                                                if (getUserType(context) ==
                                                    UserType.user) {
                                                  if (!loading) {
                                                    _wishListNotifer.value =
                                                        !_wishListNotifer.value;
                                                    await rentAdsRepository
                                                        .addToWishlist(
                                                            widget.adId)
                                                        .then((value) {
                                                      if (value.success) {
                                                        requireUpdate.value =
                                                            !requireUpdate
                                                                .value;
                                                        statefulState(() {
                                                          whishListed =
                                                              !whishListed;
                                                        });
                                                        Fluttertoast.showToast(
                                                            msg: value.data!
                                                                .toString());
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Something went wrong');
                                                      }
                                                    });
                                                    _wishListNotifer.value =
                                                        !_wishListNotifer.value;
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Please wait before new request');
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Guest user does't have this permission");
                                                }
                                              },
                                              child: !whishListed
                                                  ? const Icon(
                                                      Icons.favorite_outline,
                                                      color: Constants
                                                          .primaryColor,
                                                    )
                                                  : const Icon(
                                                      Icons.favorite,
                                                      color: Constants
                                                          .primaryColor,
                                                    ),
                                            );
                                          });
                                    });
                                  }),
                                ],
                              )
                            ],
                          );
                        }),
                  snapShot.connectionState == ConnectionState.waiting
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.shade300,
                              child: Container(
                                width: 100,
                                height: 10,
                                color: Colors.white,
                              )),
                        )
                      : Builder(builder: (context) {
                          final name = snapShot.data!.data!.user!.name;
                          return Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 2),
                          );
                        })
                ],
              ),
            ),
            _headerLocation(snapShot),
            _price(context, snapShot)
            //
          ],
        );
      });

  Widget _headerLocation(AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
      Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 5, left: 15),
          child: Row(
            children: [
              snapShot.connectionState == ConnectionState.waiting
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Shimmer.fromColors(
                          baseColor: Theme.of(context).canvasColor,
                          highlightColor: Colors.grey.shade300,
                          child: ClipOval(
                            child: Container(
                              width: 15,
                              height: 15,
                              color: Theme.of(context).canvasColor,
                            ),
                          )),
                    )
                  : const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Constants.primaryColor,
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: snapShot.connectionState == ConnectionState.waiting
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Shimmer.fromColors(
                            baseColor: Theme.of(context).canvasColor,
                            highlightColor: Colors.grey.shade300,
                            child: Container(
                              width: 100,
                              height: 15,
                              color: Theme.of(context).canvasColor,
                            )),
                      )
                    : Builder(builder: (context) {
                        final adResponse = snapShot.data!.data;

                        return Text(
                          "${adResponse!.adLocation!.locality != null ? '${adResponse.adLocation!.locality},' : ''} ${adResponse.adLocation!.district}, ${adResponse.adLocation!.state}, ${adResponse.adLocation!.country}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                        );
                      }),
              )
            ],
          ),
        );
      });

  Widget _price(
          BuildContext context, AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
      Padding(
        padding: const EdgeInsets.only(top: 10, left: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            snapShot.connectionState == ConnectionState.waiting
                ? Shimmer.fromColors(
                    baseColor: Theme.of(context).canvasColor,
                    highlightColor: Colors.grey.shade300,
                    child: Container(
                      color: Colors.white,
                      height: 15,
                      width: 200,
                    ),
                  )
                : Builder(builder: (context) {
                    final leastPrice = findLeastItem(snapShot
                        .data!.data!.adPriceDetails
                        .map((e) => e.rentPrice)
                        .toList());
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${leastPrice.value}/${snapShot.data!.data!.adPriceDetails[leastPrice.key].rentDuration}',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(),
                        ),
                        if (snapShot.data!.data!.adPriceDetails.length > 1)
                          Builder(builder: (context) {
                            String message = '';
                            for (var element
                                in snapShot.data!.data!.adPriceDetails) {
                              message +=
                                  '₹${element.rentPrice}/ ${element.rentDuration} \n';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Tooltip(
                                  showDuration: const Duration(seconds: 5),
                                  triggerMode: TooltipTriggerMode.tap,
                                  message: message,
                                  child: ClipOval(
                                    child: Container(
                                      color: Colors.black,
                                      child: const Icon(
                                        Icons.expand_more_sharp,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                            );
                          })
                      ],
                    );
                  }),
          ],
        ),
      );

  Widget _description(AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
      Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: snapShot.connectionState == ConnectionState.waiting
              ? Shimmer.fromColors(
                  baseColor: Theme.of(context).canvasColor,
                  highlightColor: Colors.grey.shade300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 250,
                        height: 15,
                        color: Colors.white,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 200,
                        height: 15,
                        color: Colors.white,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 150,
                        height: 15,
                        color: Colors.white,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 150,
                        height: 15,
                        color: Colors.white,
                      )
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localisation(context).description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(height: 1.5, fontWeight: FontWeight.w700),
                    ),
                    Builder(builder: (context) {
                      return Text(snapShot.data!.data!.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(height: 1.5));
                    })
                  ],
                ),
        );
      });

  Widget adIdandDate(
      BuildContext context, AsyncSnapshot<DataSet<AdResponse?>> snapShot) {
    return snapShot.connectionState == ConnectionState.waiting
        ? Shimmer.fromColors(
            baseColor: Theme.of(context).canvasColor,
            highlightColor: Colors.grey.shade300,
            child: Container(
              color: Theme.of(context).canvasColor,
              width: 200,
              height: 15,
            ),
          )
        : Builder(
            builder: (context) {
              return Row(
                children: [
                  // Text(
                  //   'Post ID: ${snapShot.data!.data!.adId}',
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .bodySmall!
                  //       .copyWith(fontSize: 13),
                  // ),
                  SelectableText(
                    'Post ID: ${snapShot.data!.data!.adId}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    'Posted On: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(snapShot.data!.data!.createdAt))}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 13),
                  ),
                ],
              );
            },
          );
  }

  Widget buttons(
      BuildContext context, AsyncSnapshot<DataSet<AdResponse?>> snapShot) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      child: Column(
        children: [
          if (snapShot.connectionState == ConnectionState.waiting)
            Shimmer.fromColors(
              baseColor: Theme.of(context).canvasColor,
              highlightColor: Colors.grey.shade300,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(5)),
                  )
                ],
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.amber),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  print(snapShot.data!.data!);
                  if (getUserType(context) == UserType.guest) {
                    Fluttertoast.showToast(
                        msg: 'Guest user cannot access this option');
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => ContactWidgetDialog(
                        userId: snapShot.data!.data!.userId,
                        ad: adDetails,
                      ),
                    );
                  }
                },
                child: Text(localisation(context).viewContact),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          RouteConstants.userProfile,
                          arguments: snapShot.data!.data!.userId);
                    },
                    child: Text(localisation(context).viewProfile)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
