// ignore_for_file: unnecessary_import, depend_on_referenced_packages

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/constants.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/widgets/map_widget.dart';
import 'package:elk/shared/loading_dialog.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AdPreviewScreen extends StatefulWidget {
  final int adId;

  const AdPreviewScreen(this.adId, {super.key});

  @override
  State<AdPreviewScreen> createState() {
    return _AdPreviewScreenState();
  }
}

class _AdPreviewScreenState extends State<AdPreviewScreen> {
  late final rentAdsRepo = RepositoryProvider.of<RentAdsRepository>(context);
  Future<DataSet<AdResponse?>>? future;
  double? width;
  double? height;
  final PageController _pageController = PageController();
  @override
  void initState() {
    future = rentAdsRepo.getAdDetails(widget.adId);
    super.initState();
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
    ], text: '''Title : $title\n Description: ${description.substring(0, description.length > 40 ? 40 : description.length)}...\n Check now : https://api.elkcompany.online/ad/${widget.adId}''')
        .then((value) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    future = rentAdsRepo.getAdDetails(widget.adId);
    width = MediaQuery.of(context).size.width - 40;
    height = 200;
    return PopScope(
        canPop: false,
        onPopInvoked: (value) {
          if (value) {
            return;
          }
          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(body: futureBuilder()));
  }

  Widget futureBuilder() {
    return FutureBuilder(
        future: future,
        builder: (context, snapShot) => customScrollView(snapShot));
  }

  Widget customScrollView(AsyncSnapshot<DataSet<AdResponse?>> snapShot) {
    if (snapShot.connectionState == ConnectionState.done &&
        (!snapShot.data!.success || snapShot.data!.data == null)) {
      return const Center(child: Text('Somethink went wrong'));
    }
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildListDelegate([
          _imageSlider(snapShot),
          _header(snapShot),
          const Padding(
              padding: EdgeInsets.only(left: 20, right: 20), child: Divider()),
          _description(snapShot),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
            child: adIdandDate(snapShot),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
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
                    width: width!,
                    height: height!,
                    latitude:
                        double.parse(snapShot.data!.data!.adLocation!.latitude),
                    longitude: double.parse(
                        snapShot.data!.data!.adLocation!.longitude)),
          )
        ]))
      ],
    );
  }

  Widget _imageSlider(AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
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
                              itemBuilder: ((context, index) =>
                                  CachedNetworkImage(
                                    useOldImageOnUrlChange: true,
                                    fadeInDuration:
                                        const Duration(milliseconds: 100),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 100),
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade50,
                                    ),
                                    imageUrl: list[index].image,
                                    fit: BoxFit.cover,
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
                              while (Navigator.of(context).canPop()) {
                                Navigator.pop(context);
                              }
                            },
                          )),
                    )),
                  )
                : const SizedBox()
          ],
        );
      });

  Widget _header(AsyncSnapshot<DataSet<AdResponse?>> snapShot) =>
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
                                      .copyWith(
                                          overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    shareAd(
                                        title,
                                        snapShot.data!.data!.description,
                                        snapShot
                                            .data!.data!.adImages.first.image);
                                  },
                                  child: const Icon(
                                    Icons.share,
                                    color: Constants.primaryColor,
                                  ),
                                ),
                              ),
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
            _price(snapShot)
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
                      color: Colors.red,
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

  Widget _price(AsyncSnapshot<DataSet<AdResponse?>> snapShot) => Padding(
        padding: const EdgeInsets.only(top: 10, left: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            snapShot.connectionState == ConnectionState.waiting
                ? Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Colors.grey.shade300,
                    child: Container(
                      height: 15,
                      width: 100,
                      color: Colors.white,
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
                  })
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

  Widget adIdandDate(AsyncSnapshot<DataSet<AdResponse?>> snapShot) {
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
        : Builder(builder: (context) {
            return Row(
              children: [
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
          });
  }
}
