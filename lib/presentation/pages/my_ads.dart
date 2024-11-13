// ignore_for_file: unused_import, unnecessary_import, sized_box_for_whitespace

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/bloc/event/myads_event.dart';
import 'package:elk/bloc/myads_bloc.dart';
import 'package:elk/bloc/state/myads_state.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/widgets/empty_list.dart';
import 'package:elk/presentation/widgets/error_widget.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/shared/ad_delete_dialog.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() {
    return _MyAdsScreenBody();
  }
}

class _MyAdsScreenBody extends State<MyAdsScreen> {
  late final MyAdsBloc myAdsBloc = BlocProvider.of<MyAdsBloc>(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, provider, child) {
        debugPrint('app auth provider updated');
        if (provider.authUser!.userType == UserType.user) {
          myAdsBloc.add(MyAdsLoadEvent());
        }
        return Scaffold(
            backgroundColor: Theme.of(context).canvasColor,
            appBar: AppBar(
              title: Text(localisation(context).myBuisiness),
              centerTitle: true,
              elevation: 1,
              shadowColor: Colors.black,
            ),
            body: provider.authUser!.userType == UserType.user
                ? BlocBuilder<MyAdsBloc, MyAdsState>(
                    bloc: myAdsBloc,
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.error) {
                        return const Center(
                          child: ErrorScreenWidget('Something went wrong'),
                        );
                      } else if (state.listAdresponses.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 70),
                          child: EmptyList(
                              localisation(context).youDontHavePostedYet),
                        );
                      } else {
                        return ListView.builder(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20, bottom: 70),
                            itemCount: state.listAdresponses.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    // searchBar(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            localisation(context).totalPosts,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(),
                                          ),
                                          Text(
                                            state.listAdresponses.length
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color:
                                                        Colors.grey.shade500),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return adsSingleItem(
                                  state.listAdresponses[index - 1]);
                            });
                      }
                    })
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 70),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            '${StringConstants.imageAssetsPath}/locked.png',
                            width: 100,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "You don't have permission to access this option",
                            textAlign: TextAlign.center,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              "Please sign in",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, RouteConstants.login);
                              },
                              child: const Text(
                                "Sign in",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
      },
    );
  }

  Widget searchBar() {
    final TextEditingController searchController = TextEditingController();
    return Center(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(left: 0),
        child: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget adsSingleItem(AdResponse adResponse) {
    bool isOnline = adResponse.adStatus == 'online' ? true : false;
    return StatefulBuilder(builder: (context, statefulState) {
      return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 90,
                      height: 70,
                      child: CachedNetworkImage(
                          imageUrl: adResponse.adImages.first.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                                color: Colors.grey.shade300,
                              )),
                    )),
                Builder(builder: (context) {
                  final leastPrice = findLeastItem(adResponse.adPriceDetails
                      .map((e) => e.rentPrice)
                      .toList());
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectableText(
                                '${adResponse.adId}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: const Color(0xFF4Fbbb4)),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.red.withOpacity(0.3)),
                                child: Text(
                                  adResponse.adType,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  adResponse.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                          overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '₹${leastPrice.value}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.red),
                                  ),
                                  Text(
                                    '(${adResponse.adPriceDetails[leastPrice.key].rentDuration})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Transform.scale(
                                scale: 0.6,
                                child: SizedBox(
                                  height: 20,
                                  width: 40,
                                  child: Switch(
                                      activeColor: const Color(0xFF4Fbbb4),
                                      value: isOnline,
                                      onChanged: (value) async {
                                        statefulState(() {
                                          isOnline = !isOnline;
                                        });
                                        await myAdsBloc.rentAdsRepository
                                            .changeOnlineStatus(adResponse.adId)
                                            .then((value) {
                                          if (value.success) {
                                            Fluttertoast.showToast(
                                                msg: value.data!);
                                          } else {
                                            statefulState(() {
                                              isOnline = !isOnline;
                                            });
                                            Fluttertoast.showToast(
                                                msg: value.message ?? '');
                                          }
                                        });
                                      }),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  isOnline
                                      ? localisation(context).online
                                      : localisation(context).offline,
                                  style: const TextStyle(
                                    fontSize: 9,
                                  ),
                                  // style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                })
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10)),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(adResponse.adViewsCount.toString()),
                        )
                      ],
                    ),
                    VerticalDivider(
                      color: Colors.grey.shade400,
                      width: 10,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(adResponse.adWishlistsCount.toString()),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                      child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                          RouteConstants.previewPost,
                          arguments: adResponse.adId);
                    },
                    child: Text(
                      localisation(context).preview,
                      style: const TextStyle(
                        color: Color(0xFF4Fbbb4),
                      ),
                    ),
                  )),
                ),
                Expanded(
                  child: SizedBox(
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteConstants.adPostStageinitial,
                                arguments: {
                                  'editing': true,
                                  'adId': adResponse.adId
                                });
                          },
                          child: Text(
                            localisation(context).edit,
                            style: const TextStyle(
                              color: Color(0xFF4Fbbb4),
                            ),
                          ))),
                ),
                Expanded(
                  child: SizedBox(
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AdDeleteDialog(
                                adId: adResponse.adId,
                                title: adResponse.title,
                              ),
                            );
                          },
                          child: Text(
                            localisation(context).delete,
                            style: const TextStyle(
                              color: Color(0xFF4Fbbb4),
                            ),
                          ))),
                )
              ],
            )
          ],
        ),
      );
    });
  }
}
