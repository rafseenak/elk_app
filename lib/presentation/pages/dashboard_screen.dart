// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:async';
import 'package:elk/success_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:app_links/app_links.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/bottom_navigation_item.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/presentation/pages/account_screen.dart';
import 'package:elk/presentation/pages/home_screen.dart';
import 'package:elk/presentation/pages/my_ads.dart';
import 'package:elk/presentation/pages/services_screen.dart';
import 'package:elk/presentation/widgets/location_warning_bottomsheet.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/shared/profile_complete_dialog.dart';
import 'package:elk/shared/user_sign_bottomsheet.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashBoardScreen>
    with AutomaticKeepAliveClientMixin {
  late final locationRepo = RepositoryProvider.of<LocationRepository>(context);
  late final locationCubit = BlocProvider.of<LocationCubit>(context);
  late final UserRepository userRepository =
      RepositoryProvider.of<UserRepository>(context);
  int screenIndex = 0;
  List<int> activeIndexed = [0];
  DateTime? currentBackPressTime;
  StreamSubscription<Uri>? _streamSubscription;

  late List<BottomNavigationItem> naviagationItems = [
    BottomNavigationItem(
        label: localisation(context).home,
        icon: '${StringConstants.svgAssetsPath}/home.svg'),
    BottomNavigationItem(
        label: localisation(context).services,
        icon: '${StringConstants.svgAssetsPath}/services.svg'),
    BottomNavigationItem(
        label: localisation(context).myBusibess,
        icon: '${StringConstants.svgAssetsPath}/activity.svg'),
    BottomNavigationItem(
        label: localisation(context).account,
        icon: '${StringConstants.svgAssetsPath}/account.svg')
  ];

  @override
  void initState() {
    super.initState();
    loadLocationBtmsht();
    notification();
    appLink();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void appLink() {
    final applink = AppLinks();
    _streamSubscription = applink.uriLinkStream.listen((url) {
      if (url.toString().contains('/ad')) {
        int id = int.parse(path.basename(url.path));
        Navigator.pushNamed(context, RouteConstants.rentItem, arguments: id);
      }
    });
  }

  void initnaviagationItems() {
    naviagationItems = [
      BottomNavigationItem(
          label: localisation(context).home,
          icon: '${StringConstants.svgAssetsPath}/home.svg'),
      BottomNavigationItem(
          label: localisation(context).services,
          icon: '${StringConstants.svgAssetsPath}/services.svg'),
      BottomNavigationItem(
          label: localisation(context).myBusibess,
          icon: '${StringConstants.svgAssetsPath}/activity.svg'),
      BottomNavigationItem(
          label: localisation(context).account,
          icon: '${StringConstants.svgAssetsPath}/account.svg')
    ];
  }

  Future<void> notification() async {
    var notification = await notificationStatus();
    if (notification.isDenied) {
      var newNotification = await notificationRequest();
      if (newNotification.isGranted) {
        FirebasePush.enableToken();
      }
    } else if (notification.isPermanentlyDenied) {}
  }

  Future<void> loadLocationBtmsht() async {
    await locationRepo.getLocation().then((value) {
      if (value == null) {
        showModalBottomSheet(
            isScrollControlled: true,
            enableDrag: false,
            isDismissible: false,
            context: context,
            builder: (context) => LocationChooserWarning());
      } else {
        locationCubit.changeLocation(value);
      }
    });
  }

  bool profileUpdateRequired(AppAuthProvider appAuthProvider) {
    final user = appAuthProvider.authUser;
    if (user!.name == null || user.name!.isEmpty) {
      return true;
    }
    if ((user.email == null || user.email!.isEmpty) &&
        (user.mobile == null || user.mobile!.isEmpty)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    RepositoryProvider.of<PlaceRepository>(context);
    initnaviagationItems();
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (screenIndex > 0) {
          setState(() {
            screenIndex = 0;
          });
        } else {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: 'Press back again to exit');
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
      },
      child:
          Consumer<AppAuthProvider>(builder: (context, appAuthProvider, child) {
        return BlocBuilder<LocationCubit, LocationState>(
            bloc: BlocProvider.of<LocationCubit>(context),
            builder: (context, state) {
              if (state is LocationInitialState) {
                return const Scaffold(
                    body: Center(
                  child: CircularProgressIndicator(),
                ));
              }
              return Scaffold(
                extendBody: true,
                body: IndexedStack(
                  index: screenIndex,
                  children: [
                    activeIndexed.contains(0)
                        ? const HomeScreen()
                        : const SizedBox(),
                    activeIndexed.contains(1)
                        ? const ServicesScreen()
                        : const SizedBox(),
                    activeIndexed.contains(2)
                        ? const MyAdsScreen()
                        : const SizedBox(),
                    activeIndexed.contains(3)
                        ? const AccountScreen()
                        : const SizedBox(),
                  ],
                ),
                bottomNavigationBar: bottomBar,
                floatingActionButton: FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    if (appAuthProvider.authUser!.userType == UserType.user) {
                      Navigator.pushNamed(
                          context, RouteConstants.adPostStageinitial,
                          arguments: {'editing': false});
                    } else {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => const UserSignInSheet());
                    }
                  },
                  child: const Icon(
                    Icons.add,
                    color: Constants.primaryColor,
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniCenterDocked,
              );
            });
      }),
    );
  }

  Widget get bottomBar => Builder(
        builder: (context) => BottomAppBar(
          elevation: 10,
          shadowColor: Colors.grey,
          height: 60,
          shape: const CircularNotchedRectangle(),
          padding: EdgeInsets.zero,
          notchMargin: 4,
          surfaceTintColor: Theme.of(context).canvasColor,
          color: Theme.of(context).canvasColor,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  screenIndex = 0;
                  activeIndexed.add(screenIndex);
                  setState(() {});
                },
                icon: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(naviagationItems[0].icon,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                            screenIndex == 0
                                ? Constants.primaryColor
                                : Colors.grey,
                            BlendMode.srcIn)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(naviagationItems[0].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: screenIndex == 0
                                ? Constants.primaryColor
                                : Colors.grey))
                  ],
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  screenIndex = 1;
                  activeIndexed.add(screenIndex);

                  setState(() {});
                },
                icon: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(naviagationItems[1].icon,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                            screenIndex == 1
                                ? Constants.primaryColor
                                : Colors.grey,
                            BlendMode.srcIn)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(naviagationItems[1].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: screenIndex == 1
                                ? Constants.primaryColor
                                : Colors.grey))
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  screenIndex = 2;
                  activeIndexed.add(screenIndex);
                  setState(() {});
                },
                icon: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(naviagationItems[2].icon,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                            screenIndex == 2
                                ? Constants.primaryColor
                                : Colors.grey,
                            BlendMode.srcIn)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(naviagationItems[2].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: screenIndex == 2
                                ? Constants.primaryColor
                                : Colors.grey))
                  ],
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  screenIndex = 3;
                  activeIndexed.add(screenIndex);
                  setState(() {});
                },
                icon: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(naviagationItems[3].icon,
                        width: 17,
                        colorFilter: ColorFilter.mode(
                            screenIndex == 3
                                ? Constants.primaryColor
                                : Colors.grey,
                            BlendMode.srcIn)),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(naviagationItems[3].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: screenIndex == 3
                                ? Constants.primaryColor
                                : Colors.grey))
                  ],
                ),
              ),
            ),
          ]),
        ),
      );

  @override
  bool get wantKeepAlive => true;
}
