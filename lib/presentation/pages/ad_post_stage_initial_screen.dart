// ignore_for_file: unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/cubit/ad_post_state.dart';
import 'package:elk/data/model/home_category.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/network/entity/ads_category.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/shared/unsaved_post_dialof.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AdPostStageInitial extends StatefulWidget {
  final bool isEditing;
  final int? adId;
  const AdPostStageInitial(this.isEditing, {this.adId, super.key});

  @override
  State<AdPostStageInitial> createState() => _AdpostStaeg1ScreenState();
}

class _AdpostStaeg1ScreenState extends State<AdPostStageInitial> {
  late final AppAuthProvider appAuthProvider =
      Provider.of<AppAuthProvider>(context, listen: false);
  late final rentAdsRepo = RepositoryProvider.of<RentAdsRepository>(context);
  late final userRepo = RepositoryProvider.of<UserRepository>(context);
  late final AdPostCubit adPostStage1Cubit =
      AdPostCubit(userRepo, rentAdsRepo, appAuthProvider.authUser!.token);

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      loadEditing(widget.adId!);
    } else {
      loadUnsaved();
    }
  }

  List rentCategoryList = [
    {
      "id": 1,
      "title": "Car",
      "category": "Cars",
      "image": "${StringConstants.iconAssetPath}/car.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 2,
      "title": "Property",
      "category": "Properties",
      "image": "${StringConstants.iconAssetPath}/property.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 3,
      "title": "Electronics",
      "category": "Electronics",
      "image": "${StringConstants.iconAssetPath}/electronics.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 4,
      "title": "Furniture",
      "category": "Furnitures",
      "image": "${StringConstants.iconAssetPath}/furniture.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 5,
      "title": "Bike",
      "category": "Bikes",
      "image": "${StringConstants.iconAssetPath}/bike.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 6,
      "title": "Cloth",
      "category": "Clothes",
      "image": "${StringConstants.iconAssetPath}/cloth.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 7,
      "title": "Helicopter",
      "category": "Helicopters",
      "image": "${StringConstants.iconAssetPath}/helicopter.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 8,
      "title": "Tools",
      "category": "Tools",
      "image": "${StringConstants.iconAssetPath}/tools.png",
      "image_for": null,
      "ad_type": "rent"
    },
    {
      "id": 16,
      "title": "Other",
      "category": "Others",
      "image": "${StringConstants.iconAssetPath}/others.png",
      "image_for": null,
      "ad_type": "rent"
    }
  ];
  late List<AdCategory> rentCategories = rentCategoryList.map((item) {
    return AdCategory(
      title: item['title'],
      category: item['category'],
      image: item['image'],
    );
  }).toList();
  List serviceCategoryList = [
    {
      "id": 9,
      "title": "Cleaning",
      "category": "Cleaning",
      "image": "${StringConstants.iconAssetPath}/cleaning.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 10,
      "title": "Repairing",
      "category": "Repairing",
      "image": "${StringConstants.iconAssetPath}/repair.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 11,
      "title": "Painting",
      "category": "Painting",
      "image": "${StringConstants.iconAssetPath}/painting.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 12,
      "title": "Electrician",
      "category": "Electrician",
      "image": "${StringConstants.iconAssetPath}/electrician.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 13,
      "title": "Carpentry",
      "category": "Carpentry",
      "image": "${StringConstants.iconAssetPath}/carpentry.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 14,
      "title": "Laundry",
      "category": "Laundry",
      "image": "${StringConstants.iconAssetPath}/laundry.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 17,
      "title": "Plumbing",
      "category": "Plumbing",
      "image": "${StringConstants.iconAssetPath}/plumbing.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 18,
      "title": "Salon",
      "category": "Salon",
      "image": "${StringConstants.iconAssetPath}/haircut.png",
      "image_for": null,
      "ad_type": "service"
    },
    {
      "id": 15,
      "title": "Other",
      "category": "Others",
      "image": "${StringConstants.iconAssetPath}/others.png",
      "image_for": null,
      "ad_type": "service"
    }
  ];
  late List<AdCategory> serviceCategories = serviceCategoryList.map((item) {
    return AdCategory(
      title: item['title'],
      category: item['category'],
      image: item['image'],
    );
  }).toList();

  Future<void> loadEditing(int adId) async {
    await adPostStage1Cubit.rentAdsRepository
        .getAdDetails(widget.adId!)
        .then((value) async {
      if (value.success) {
        debugPrint('load editng success');
        await adPostStage1Cubit.loadRecentAd(value.data!);
        if (mounted) {
          Navigator.pushReplacementNamed(context, RouteConstants.adPostStage1,
              arguments: {
                'adType': value.data!.adType,
                'title': value.data!.category,
                'adPostCubit': adPostStage1Cubit
              });
        }
      }
    });
  }

  void adCubitInit() {
    adPostStage1Cubit.iniiState();
  }

  Future<void> loadUnsaved() async {
    await adPostStage1Cubit.fetchRecentAd().then((value) {
      debugPrint(value.message.toString());
      if (value.success && value.data != null) {
        if (mounted) {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              enableDrag: false,
              isDismissible: false,
              context: context,
              builder: (context) => UnsavedPostDialog(
                    adResponse: value.data!,
                    adPostCubit: adPostStage1Cubit,
                  ));
        }
      } else {
        adCubitInit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostCubit, AdPostState>(
        bloc: adPostStage1Cubit,
        builder: (context, state) {
          if (state is AdPostInitialState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AdPostLoadState) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('${localisation(context).whatAreYouOffering} ?'),
                  centerTitle: true,
                  titleTextStyle: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle!
                      .copyWith(fontSize: 17),
                  titleSpacing: 0,
                  bottom: TabBar(tabs: [
                    Tab(
                      text: localisation(context).renting,
                    ),
                    Tab(
                      text: localisation(context).service,
                    )
                  ]),
                ),
                body: TabBarView(children: [
                  Container(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: _rentingItemsGrid('rent', rentCategories),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: _rentingItemsGrid('service', serviceCategories),
                  )
                ]),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _rentingItemsGrid(String adType, List<AdCategory> list) {
    return GridView.builder(
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.8,
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      itemBuilder: (BuildContext context, int index) =>
          _rentItem(adType, list[index]),
    );
  }

  Widget _rentItem(String adType, AdCategory category) {
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    category.image,
                    width: 50,
                    height: 50,
                  ),
                  // CachedNetworkImage(imageUrl: category.image),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      localisationSwitch(context, category.title),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Positioned.fill(
                child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: () {
                Navigator.pushNamed(context, RouteConstants.adPostStage1,
                    arguments: {
                      'adType': adType,
                      'title': category.title,
                      'category': category.category,
                      'adPostCubit': adPostStage1Cubit
                    });
              }),
            ))
          ],
        ));
  }
}
