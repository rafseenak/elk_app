// ignore_for_file: unused_import, unnecessary_cast, unnecessary_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/home_cubit.dart';
import 'package:elk/cubit/home_state.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/cubit/service_cubit.dart';
import 'package:elk/cubit/service_state.dart';
import 'package:elk/data/model/home_category.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/pages/location_search_screen.dart';
import 'package:elk/presentation/widgets/common_button.dart';
import 'package:elk/presentation/widgets/location_warning_bottomsheet.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _HomeState();
}

class _HomeState extends State<ServicesScreen>
    with AutomaticKeepAliveClientMixin {
  late final serviceCubit =
      ServiceCubit(RepositoryProvider.of<RentAdsRepository>(context));
  late final locationCubit = BlocProvider.of<LocationCubit>(context);
  late List<HomeCategory> _homeCategories = [
    HomeCategory(
        category: 'Cleaning',
        title: localisation(context).cleaning,
        image: '${StringConstants.imageAssetsPath}/ic_cleaning_service.png'),
    HomeCategory(
        category: 'Repairing',
        title: localisation(context).repairing,
        image: '${StringConstants.imageAssetsPath}/ic_repairing_service.png'),
    HomeCategory(
        category: 'Painting',
        title: localisation(context).paiting,
        image: '${StringConstants.imageAssetsPath}/ic_painting_service.png'),
    HomeCategory(
        category: 'Plumbing',
        title: localisation(context).plumbing,
        image: '${StringConstants.imageAssetsPath}/ic_plumbing_service.png'),
    HomeCategory(
        category: 'Electrician',
        title: localisation(context).electrician,
        image: '${StringConstants.imageAssetsPath}/ic_electrician_service.png'),
    HomeCategory(
        category: 'Carpentry',
        title: localisation(context).carpentry,
        image: '${StringConstants.imageAssetsPath}/ic_carpentry_service.png'),
    HomeCategory(
        category: 'Laundry',
        title: localisation(context).laundry,
        image: '${StringConstants.imageAssetsPath}/ic_laudery_service.png'),
    HomeCategory(
        category: 'Salon',
        title: localisation(context).saloon,
        image: '${StringConstants.imageAssetsPath}/ic_saloon_service.png'),
  ];

  initHomeCategories() {
    _homeCategories = [
      HomeCategory(
          category: 'Cleaning',
          title: localisation(context).cleaning,
          image: '${StringConstants.imageAssetsPath}/ic_cleaning_service.png'),
      HomeCategory(
          category: 'Repairing',
          title: localisation(context).repairing,
          image: '${StringConstants.imageAssetsPath}/ic_repairing_service.png'),
      HomeCategory(
          category: 'Painting',
          title: localisation(context).paiting,
          image: '${StringConstants.imageAssetsPath}/ic_painting_service.png'),
      HomeCategory(
          category: 'Plumbing',
          title: localisation(context).plumbing,
          image: '${StringConstants.imageAssetsPath}/ic_plumbing_service.png'),
      HomeCategory(
          category: 'Electrition',
          title: localisation(context).electrician,
          image:
              '${StringConstants.imageAssetsPath}/ic_electrician_service.png'),
      HomeCategory(
          category: 'Carpentry',
          title: localisation(context).carpentry,
          image: '${StringConstants.imageAssetsPath}/ic_carpentry_service.png'),
      HomeCategory(
          category: 'Laundry',
          title: localisation(context).laundry,
          image: '${StringConstants.imageAssetsPath}/ic_laudery_service.png'),
      HomeCategory(
          category: 'Salon',
          title: localisation(context).saloon,
          image: '${StringConstants.imageAssetsPath}/ic_saloon_service.png'),
    ];
  }

  @override
  void initState() {
    super.initState();
    serviceCubit.bestServiceProviders(
        (locationCubit.state as LocationLoadState).location);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    initHomeCategories();
    return BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
      if (locationState is LocationInitialState) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return BlocBuilder<ServiceCubit, ServiceState>(
          bloc: serviceCubit,
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: searchBar(),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25, top: 20),
                          child: text(localisation(context).categories),
                        ),
                        Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: categories()),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                          ),
                          child:
                              text(localisation(context).bestServiceProvider),
                        ),
                        if (state is ServiceStateInitial)
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: double.infinity, minHeight: 400),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: (state as ServiceLoadState)
                                    .currentData
                                    .isNotEmpty
                                ? bestServiceProviders(
                                    state as ServiceLoadState)
                                : Container(
                                    constraints: const BoxConstraints(
                                        minWidth: double.infinity,
                                        minHeight: 300),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            '${StringConstants.imageAssetsPath}/empty_box.png',
                                            width: 100,
                                            height: 100,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(localisation(context)
                                              .noServiceProviders),
                                        ],
                                      ),
                                    ),
                                  ),
                          )
                      ]),
                ),
              ),
            );
          });
    });
  }

  Widget searchBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 60),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  left: 10, top: 10, bottom: 10, right: 10),
              decoration: BoxDecoration(
                  color: const Color(0XFFEAEAEA),
                  borderRadius: BorderRadius.circular(10)),
              child: IntrinsicHeight(
                child: Row(children: [
                  Expanded(
                      child: Text(
                    localisation(context).searchElectricianPlumberEtc,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey,
                        ),
                    maxLines: 1,
                  )),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const Icon(
                    Icons.search,
                    color: Colors.grey,
                  )
                ]),
              ),
            ),
            Positioned.fill(
                child: Material(
              color: const Color.fromARGB(0, 165, 133, 133),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.searchRentItem,
                        arguments: {'adType': 'service'});
                  }),
            ))
          ],
        ),
      ),
    );
  }

  Widget text(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 15),
    );
  }

  Widget categories() {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _homeCategories.length,
      itemBuilder: (context, index) =>
          categoryItem(_homeCategories[index], index),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.85,
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20),
    );
  }

  Widget categoryItem(HomeCategory category, int index) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(RouteConstants.rentCategory, arguments: {
            'adType': 'service',
            'category': _homeCategories[index].category,
          });
        },
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                category.image,
                width: 50,
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  category.title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 12),
                ),
              )
            ]),
      ),
    );
  }

  Widget bestServiceProviders(ServiceLoadState state) {
    return GridView.count(
      primary: false,
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 0.8,
      padding: const EdgeInsets.only(bottom: 70),
      children:
          state.currentData.map((e) => bestServiceProvidersItem(e)).toList(),
    );
  }

  Widget bestServiceProvidersItem(AdResponse adResponse) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                  builder: (context, constraints) => CachedNetworkImage(
                        imageUrl: adResponse.adImages[0].image,
                        width: double.infinity,
                        height: 90,
                        fit: BoxFit.cover,
                        memCacheWidth: constraints.maxWidth.toInt() * 2,
                        memCacheHeight: 200,
                      )),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  adResponse.title,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 5),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.2)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 2, bottom: 2),
                      child: Text(
                        adResponse.category,
                        style: GoogleFonts.poppins(
                            color: Constants.primaryColor, fontSize: 11),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Constants.primaryColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          adResponse.adLocation == null
                              ? ''
                              : "${adResponse.adLocation!.locality != null ? '${adResponse.adLocation!.locality},' : ''} ${adResponse.adLocation!.district}, ${adResponse.adLocation!.state}, ${adResponse.adLocation!.country}",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(),
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 7, top: 4),
                  child: Text(
                    adResponse.distance != null
                        ? convertToMeterOrKelometer(
                            adResponse.distance!,
                          )
                        : '',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 7, top: 4),
                  child: RichText(
                    text: TextSpan(
                        text: 'From ',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey, fontWeight: FontWeight.w700),
                        children: [
                          TextSpan(
                              text:
                                  '₹${findLeastItem(adResponse.adPriceDetails.map((e) => e.rentPrice).toList()).value}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontSize: 11,
                                      color: Constants.primaryColor,
                                      fontWeight: FontWeight.w700))
                        ]),
                  ))
            ],
          ),
          Positioned(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteConstants.rentItem,
                          arguments: adResponse.adId);
                    },
                  )))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
