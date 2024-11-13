/* import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/bloc/language_selection_bloc.dart';
import 'package:elk/bloc/otp_screen_bloc.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/rent_products_cubit.dart';
import 'package:elk/cubit/search_rent_item_cubit.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/main.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/pages/ad_post_stage_1_screen.dart';
import 'package:elk/presentation/pages/ad_post_stage_2_screen.dart';
import 'package:elk/presentation/pages/ad_post_stage_3.dart';
import 'package:elk/presentation/pages/ad_post_stage_initial_screen.dart';
import 'package:elk/presentation/pages/ad_post_success_scree.dart';
import 'package:elk/presentation/pages/ad_preview.dart';
import 'package:elk/presentation/pages/auth_update_screen.dart';
import 'package:elk/presentation/pages/location_chooser.dart';
import 'package:elk/presentation/pages/location_search_screen.dart';
import 'package:elk/presentation/pages/profile_screen.dart';
import 'package:elk/presentation/pages/profile_update_screen.dart';
import 'package:elk/presentation/pages/rent_item_screen.dart';
import 'package:elk/presentation/pages/rent_prodcuts_screen.dart';
import 'package:elk/presentation/pages/search_rent_item_screen.dart';
import 'package:elk/presentation/pages/user_profile.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/presentation/pages/dashboard_screen.dart';
import 'package:elk/presentation/pages/language_selection_screen.dart';
import 'package:elk/presentation/pages/login_screen.dart';
import 'package:elk/presentation/pages/otp_screen.dart';
import 'package:elk/presentation/pages/splash_screen.dart';
import 'package:elk/provider/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GoRoutes {
  static GoRouter goRoutesUnAuthenticated =
      GoRouter(initialLocation: RouteConstants.language, routes: [
    GoRoute(
      path: RouteConstants.language,
      builder: (context, state) {
        return LanguageSelectionScreen(
          languageSelectionBloc: LanguageSelectionBloc(),
        );
      },
    ),
    GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => LoginScreen(
              authBloc: LoginScreenBloc(),
            )),
    GoRoute(
      path: RouteConstants.otp,
      builder: (context, state) {
        Map datas = state.extra as Map;
        return OTPScreen(
          otpScreenBloc: OTPSreenBloc(
            phoneNumber: datas['phoneNumber'],
            verificationId: datas['verificationId'],
            resendToken: datas['resendToken'],
          ),
        );
      },
    ),
  ]);

  static GoRouter goRoutes = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: RouteConstants.dashboard,
      routes: [
        GoRoute(
          path: RouteConstants.dashboard,
          builder: (context, state) => const DashBoardScreen(),
        ),
        GoRoute(
            path: RouteConstants.locationSearch,
            builder: (context, state) => LocationSearch(
                  locationSearchCubit: LocationSearchCubit(
                      placeRepository: Provider.of<PlaceRepository>(context)),
                )),
        GoRoute(
            path: RouteConstants.rentCategory,
            builder: (context, state) {
              final rentAdsRepo =
                  RepositoryProvider.of<RentAdsRepository>(context);
              final extras = state.extra as Map<String, dynamic>;
              return RentProductsScreen(
                category: extras['category'],
                adType: extras['adType'],
                keyword:
                    extras.containsKey('keyword') ? extras['keyword'] : null,
                rentProductsCubit: RentProductsCubit(rentAdsRepo),
              );
            }),
        GoRoute(
          path: RouteConstants.rentItem,
          pageBuilder: (context, state) {
            final extras = state.extra as int;
            return MaterialPage(
                key: state.pageKey,
                child: RentItemScreen(
                  adId: extras,
                ));
          },
        ),
        GoRoute(
            path: RouteConstants.searchRentItem,
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>;
              return SearchRentItemScreen(extras['adType']);
            }),
        GoRoute(
            path: RouteConstants.adPostStageinitial,
            builder: (context, state) {
              final extra = state.extra as bool;
              return AdPostStageInitial(extra);
            }),
        GoRoute(
            path: RouteConstants.adPostStage1,
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>;
              return AdPostStage1(extras['adType'], extras['title'],
                  extras['category'], extras['adPostCubit']);
            }),
        GoRoute(
            path: RouteConstants.profileScreen,
            builder: (context, state) {
              final isrequired =
                  state.extra == null ? false : (state.extra as bool);
              return ProfileScreen(
                updateRequired: isrequired,
              );
            }),
        GoRoute(
            path: RouteConstants.authUpdate,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AuthUpdateScreen(
                profileProvider: extra['profileProvider'],
                authType: extra['authType'],
                value: extra['authValue'],
              );
            }),
        GoRoute(
            path: RouteConstants.profileUpdate,
            builder: (context, state) {
              final extra = state.extra as ProfileProvider;
              return ProfileUpdateScreen(
                profileProvider: extra,
              );
            }),
        GoRoute(
            path: RouteConstants.adPostStage2,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AdPostStage2Screen(
                  extra['categoryTitle'], extra['adPostCubit']);
            }),
        GoRoute(
            path: RouteConstants.adPostStage3,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AdPostStage3Screen(
                  extra['categoryTitle'], extra['adPostCubit']);
            }),
        GoRoute(
            path: RouteConstants.locationChooswer,
            builder: (context, state) {
              return LocationChooser();
            }),
        GoRoute(
            path: RouteConstants.postSuccess,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AdPostSuccessScreen(
                  extra['fromEdit'] ?? false, extra['adId']);
            }),
        GoRoute(
            path: RouteConstants.previewPost,
            builder: (context, state) {
              final extra = state.extra as int;
              return AdPreviewScreen(extra);
            }),
        GoRoute(
            path: RouteConstants.userProfile,
            builder: (context, state) {
              final extra = state.extra as int;
              return UserProfile(extra);
            })
      ]);
}
 */