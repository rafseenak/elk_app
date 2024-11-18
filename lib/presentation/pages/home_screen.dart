// ignore_for_file: unused_import, unnecessary_import, unnecessary_cast, use_build_context_synchronously

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_bloc.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_event.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_state.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/home_cubit.dart';
import 'package:elk/cubit/home_state.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/model/home_category.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/chat/chat_service.dart';
import 'package:elk/presentation/pages/chat_list_screen.dart';
import 'package:elk/presentation/pages/chat_list_screen2.dart';
import 'package:elk/presentation/pages/location_search_screen.dart';
import 'package:elk/presentation/widgets/common_button.dart';
import 'package:elk/presentation/widgets/home_recomented_grid_item.dart';
import 'package:elk/presentation/widgets/location_warning_bottomsheet.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late final locationCubit = BlocProvider.of<LocationCubit>(context);
  late final placeRepository = RepositoryProvider.of<PlaceRepository>(context);
  final ChatService chatService = ChatService();
  ApiClient apiClient = GetIt.I<ApiClient>();

  late final systemUiOverlayStyle =
      ValueNotifier(Theme.of(context).appBarTheme.systemOverlayStyle);
  late final HomeCubit _homeCubit =
      HomeCubit(RepositoryProvider.of<RentAdsRepository>(context));
  late final AppAuthProvider _authProvider =
      Provider.of<AppAuthProvider>(context, listen: false);

  late List<HomeCategory> _homeCategories = [
    HomeCategory(
        category: 'Cars',
        title: localisation(context).cars,
        image: '${StringConstants.imageAssetsPath}/home_cate_cars.png'),
    HomeCategory(
        category: 'Properties',
        title: localisation(context).properties,
        image: '${StringConstants.imageAssetsPath}/home_cate_properties.png'),
    HomeCategory(
        category: 'Electronics',
        title: localisation(context).electronics,
        image: '${StringConstants.imageAssetsPath}/home_cate_electronics.png'),
    HomeCategory(
        category: 'Tools',
        title: localisation(context).tools,
        image: '${StringConstants.imageAssetsPath}/home_cate_tools.png'),
    HomeCategory(
        category: 'Furnitures',
        title: localisation(context).furniture,
        image: '${StringConstants.imageAssetsPath}/home_cate_furniture.png'),
    HomeCategory(
        category: 'Bikes',
        title: localisation(context).bikes,
        image: '${StringConstants.imageAssetsPath}/home_cate_bikes.png'),
    HomeCategory(
        category: 'Clothes',
        title: localisation(context).clothes,
        image: '${StringConstants.imageAssetsPath}/home_cate_clothes.png'),
    HomeCategory(
        category: 'Helicopters',
        title: localisation(context).helicopter,
        image: '${StringConstants.imageAssetsPath}/home_cate_helicopter.png'),
  ];
  int? messageUnreadCount;

  initHomeCategories() {
    _homeCategories = [
      HomeCategory(
          category: 'Cars',
          title: localisation(context).cars,
          image: '${StringConstants.imageAssetsPath}/home_cate_cars.png'),
      HomeCategory(
          category: 'Properties',
          title: localisation(context).properties,
          image: '${StringConstants.imageAssetsPath}/home_cate_properties.png'),
      HomeCategory(
          category: 'Electronics',
          title: localisation(context).electronics,
          image:
              '${StringConstants.imageAssetsPath}/home_cate_electronics.png'),
      HomeCategory(
          category: 'Tools',
          title: localisation(context).tools,
          image: '${StringConstants.imageAssetsPath}/home_cate_tools.png'),
      HomeCategory(
          category: 'Furnitures',
          title: localisation(context).furniture,
          image: '${StringConstants.imageAssetsPath}/home_cate_furniture.png'),
      HomeCategory(
          category: 'Bikes',
          title: localisation(context).bikes,
          image: '${StringConstants.imageAssetsPath}/home_cate_bikes.png'),
      HomeCategory(
          category: 'Clothes',
          title: localisation(context).clothes,
          image: '${StringConstants.imageAssetsPath}/home_cate_clothes.png'),
      HomeCategory(
          category: 'Helicopters',
          title: localisation(context).helicopter,
          image: '${StringConstants.imageAssetsPath}/home_cate_helicopter.png'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _homeCubit.fetchRecommentedPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    initHomeCategories();
    return BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
      debugPrint('Home screen bloc updated');
      if (locationState is LocationInitialState) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return BlocBuilder<HomeCubit, HomeState>(
          bloc: _homeCubit,
          builder: (context, state) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark),
              child: Scaffold(
                  appBar: appBar(locationState as LocationLoadState),
                  body: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          )),
                      child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              searchBar(),
                              Card(
                                  color: Theme.of(context).canvasColor,
                                  surfaceTintColor:
                                      Theme.of(context).canvasColor,
                                  elevation: 1,
                                  margin: const EdgeInsets.only(
                                      left: 2, right: 3, top: 10),
                                  child: categories()),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5),
                                child: Text(
                                  localisation(context).recommentedPosts,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontSize: 15),
                                ),
                              ),
                              if (state is HomeInitialState)
                                Container(
                                  constraints: const BoxConstraints(
                                      minWidth: double.infinity,
                                      minHeight: 200),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, bottom: 70),
                                    child: (state as HomeLoadState)
                                            .currentData
                                            .isNotEmpty
                                        ? recomentedPost(state as HomeLoadState)
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
                                                      .noRecommentedPosts),
                                                ],
                                              ),
                                            ),
                                          ))
                            ]),
                      ),
                    ),
                  )),
            );
          });
    });
  }

  AppBar appBar(LocationLoadState state) {
    return AppBar(
      title: GestureDetector(
        onTap: () {
          showModalBottomSheet(
              isDismissible: false,
              enableDrag: false,
              useRootNavigator: true,
              useSafeArea: false,
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return LocationSearch(false,
                    locationSearchCubit:
                        LocationSearchCubit(placeRepository: placeRepository));
              });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                localisation(context).location,
                style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_sharp,
                  color: Colors.black,
                  size: 15,
                ),
                Text(
                    (state.location.locality != null &&
                            state.location.locality != '')
                        ? state.location.locality!
                        : (state.location.place != null &&
                                state.location.place != '')
                            ? state.location.place!
                            : (state.location.district != null &&
                                    state.location.district != '')
                                ? state.location.district!
                                : (state.location.state != null &&
                                        state.location.state != '')
                                    ? state.location.state!
                                    : (state.location.country != '')
                                        ? state.location.country
                                        : '',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                )
              ],
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () async {
              if (getUserType(context) == UserType.guest) {
                Fluttertoast.showToast(
                    msg: 'Guest user cannot access this option');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomList(
                      authUserId: _authProvider.authUser!.userId,
                    ),
                  ),
                );
                // Navigator.pushNamed(context, RouteConstants.profileScreen);
              }
            },
            icon: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                        child: StreamBuilder<AuthUser?>(
                          stream: _authProvider.authUserStram,
                          initialData: _authProvider.authUser,
                          builder: (context, snapshot) => (_authProvider
                                          .authUser!.profile !=
                                      null &&
                                  _authProvider.authUser!.profile!.isNotEmpty)
                              ? CachedNetworkImage(
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                  imageUrl: snapshot.data!.profile!,
                                )
                              : SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: Center(
                                    child: Text(
                                      (_authProvider.authUser!.name != null &&
                                              _authProvider.authUser!.name !=
                                                  '')
                                          ? _authProvider.authUser!.name!
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : 'U',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Constants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: BlocProvider(
                  //     create: (context) => ChatRoomListBloc(
                  //         authUserId: _authProvider.authUser!.userId)
                  //       ..add(LoadChatRooms(
                  //         authUserId: _authProvider.authUser!.userId,
                  //       )),
                  //     child: BlocBuilder<ChatRoomListBloc, ChatRoomListState>(
                  //       builder: (context, state) {
                  //         return Container(
                  //           width: 15,
                  //           height: 15,
                  //           decoration: const BoxDecoration(
                  //             color: Colors.red,
                  //             shape: BoxShape.circle,
                  //           ),
                  //           child: Center(
                  //             child: Text(
                  //               state.count.toString(),
                  //               style: const TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 10,
                  //               ),
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  Align(
                    alignment: Alignment.topRight,
                    child: StreamBuilder(
                      stream: apiClient
                          .getChatRoomCount(_authProvider.authUser!.userId),
                      builder: (context, snapShot) {
                        return Container(
                          width: 15,
                          height: 15,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              snapShot.hasData ? snapShot.data.toString() : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget appBat(LocationLoadState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    isDismissible: false,
                    enableDrag: false,
                    useRootNavigator: true,
                    useSafeArea: false,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return LocationSearch(false,
                          locationSearchCubit: LocationSearchCubit(
                              placeRepository: placeRepository));
                    });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      'Location',
                      style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_sharp,
                        color: Colors.black,
                        size: 15,
                      ),
                      Text(
                          (state.location.locality != null &&
                                  state.location.locality != '')
                              ? state.location.locality!
                              : (state.location.place != null &&
                                      state.location.place != '')
                                  ? state.location.place!
                                  : (state.location.district != null &&
                                          state.location.district != '')
                                      ? state.location.district!
                                      : (state.location.state != null &&
                                              state.location.state != '')
                                          ? state.location.state!
                                          : (state.location.country != '')
                                              ? state.location.country
                                              : '',
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w700)),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                      )
                    ],
                  )
                ],
              ),
            ),
            IconButton(
                iconSize: 40,
                onPressed: () {},
                icon: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: Container(
                      color: Colors.amber.shade200,
                      child: const Center(
                          child: Icon(
                        Icons.notifications,
                        size: 20,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget searchBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 60),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding:
                const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
            decoration: BoxDecoration(
                color: const Color(0XFFEAEAEA),
                borderRadius: BorderRadius.circular(10)),
            child: IntrinsicHeight(
              child: Row(children: [
                Expanded(
                    child: Text(
                  localisation(context).searchPropertiesCarsEtc,
                  style: const TextStyle(
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
              child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pushNamed(context, RouteConstants.searchRentItem,
                        arguments: {'adType': 'rent'});
                  }),
            ),
          ))
        ],
      ),
    );
  }

  Widget categories() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 10),
      primary: false,
      shrinkWrap: true,
      itemCount: _homeCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 30,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(RouteConstants.rentCategory, arguments: {
            'adType': 'rent',
            'category': _homeCategories[index].category,
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
                child: Image.asset(
              _homeCategories[index].image,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            )),
            const SizedBox(
              height: 10,
            ),
            Text(
              _homeCategories[index].title,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                  ),
            )
          ],
        ),
      ),
    );
  }

  Widget recomentedPost(HomeLoadState homeLoadState) {
    return GridView.builder(
        padding: const EdgeInsets.only(top: 15),
        primary: false,
        shrinkWrap: true,
        itemCount: homeLoadState.currentData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 180,
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 10),
        itemBuilder: (context, index) => HomeRecomentedGridItem(
              homeLoadState.currentData[index],
              key: ValueKey<int>(homeLoadState.currentData[index].adId),
            ));
  }

  @override
  bool get wantKeepAlive => true;
}
