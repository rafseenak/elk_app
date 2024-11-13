// ignore_for_file: prefer_const_constructors

import 'package:elk/bloc/language_selection_bloc.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/bloc/otp_screen_bloc.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/rent_products_cubit.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/presentation/pages/ad_post_stage_1_screen.dart';
import 'package:elk/presentation/pages/ad_post_stage_2_screen.dart';
import 'package:elk/presentation/pages/ad_post_stage_3.dart';
import 'package:elk/presentation/pages/ad_post_stage_initial_screen.dart';
import 'package:elk/presentation/pages/ad_post_success_scree.dart';
import 'package:elk/presentation/pages/ad_preview.dart';
import 'package:elk/presentation/pages/auth_update_screen.dart';
import 'package:elk/presentation/pages/dashboard_screen.dart';
import 'package:elk/presentation/pages/language_selection_screen.dart';
import 'package:elk/presentation/pages/location_chooser.dart';
import 'package:elk/presentation/pages/login_screen.dart';
import 'package:elk/presentation/pages/otp_screen.dart';
import 'package:elk/presentation/pages/product_image_viewer.dart';
import 'package:elk/presentation/pages/product_price_input.dart';
import 'package:elk/presentation/pages/profile_screen.dart';
import 'package:elk/presentation/pages/profile_update_screen.dart';
import 'package:elk/presentation/pages/rent_item_screen.dart';
import 'package:elk/presentation/pages/rent_prodcuts_screen.dart';
import 'package:elk/presentation/pages/search_rent_item_screen.dart';
import 'package:elk/presentation/pages/splash_screen.dart';
import 'package:elk/presentation/pages/user_profile.dart';
import 'package:elk/presentation/pages/wishlists.dart';
import 'package:elk/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteGenerator {
  static Route<dynamic> authenicatedRoutes(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case RouteConstants.root:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteConstants.language:
        return MaterialPageRoute(
            builder: (_) => LanguageSelectionScreen(
                  isInitialPage: args == null ? true : false,
                  languageSelectionBloc: LanguageSelectionBloc(),
                ));
      case RouteConstants.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LoginScreenBloc(),
            child: LoginScreen(),
          ),
        );

      case RouteConstants.otp:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return OTPScreen(
              otpScreenBloc: OTPSreenBloc(
                phoneNumber: args['phoneNumber'],
                verificationId: args['verificationId'],
                resendToken: args['resendToken'],
              ),
            );
          });
        }
        return _errorRoute();

      case RouteConstants.dashboard:
        return MaterialPageRoute(builder: (_) => const DashBoardScreen());

      case RouteConstants.rentCategory:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            final rentAdsRepo = RepositoryProvider.of<RentAdsRepository>(_);
            return RentProductsScreen(
              category: args['category'],
              adType: args['adType'],
              keyword: args.containsKey('keyword') ? args['keyword'] : null,
              rentProductsCubit: RentProductsCubit(rentAdsRepo),
            );
          });
        }
        return _errorRoute();

      case RouteConstants.rentItem:
        if (args is int) {
          return MaterialPageRoute(
              builder: (_) => RentItemScreen(
                    adId: args,
                  ));
        }
        return _errorRoute();

      case RouteConstants.searchRentItem:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return SearchRentItemScreen(args['adType']);
          });
        }

        return _errorRoute();

      case RouteConstants.adPostStageinitial:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AdPostStageInitial(
              args['editing'] ?? 'false',
              adId: args['adId'],
            );
          });
        }
        return _errorRoute();

      case RouteConstants.adPostStage1:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AdPostStage1(args['adType'], args['title'], args['category'],
                args['adPostCubit']);
          });
        }
        return _errorRoute();

      case RouteConstants.profileScreen:
        final isrequired = args == null ? false : (args as bool);

        return MaterialPageRoute(builder: (_) {
          return ProfileScreen(updateRequired: isrequired);
        });

      case RouteConstants.authUpdate:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AuthUpdateScreen(
              profileProvider: args['profileProvider'],
              authType: args['authType'],
              value: args['authValue'],
            );
          });
        }
        return _errorRoute();

      case RouteConstants.profileUpdate:
        if (args is ProfileProvider) {
          return MaterialPageRoute(builder: (_) {
            return ProfileUpdateScreen(
              profileProvider: args,
            );
          });
        }
        return _errorRoute();

      case RouteConstants.adPostStage2:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AdPostStage2Screen(
                args['categoryTitle'], args['adPostCubit']);
          });
        }
        return _errorRoute();

      case RouteConstants.adPostStage3:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AdPostStage3Screen(
                args['categoryTitle'], args['adPostCubit']);
          });
        }
        return _errorRoute();

      case RouteConstants.locationChooswer:
        return MaterialPageRoute(builder: (_) {
          return LocationChooser(args as bool);
        });

      case RouteConstants.postSuccess:
        if (args is Map) {
          return MaterialPageRoute(builder: (_) {
            return AdPostSuccessScreen(args['fromEdit'] ?? false, args['adId']);
          });
        }
        return _errorRoute();

      case RouteConstants.previewPost:
        if (args is int) {
          return MaterialPageRoute(builder: (_) {
            return AdPreviewScreen(args);
          });
        }
        return _errorRoute();

      case RouteConstants.userProfile:
        if (args is int?) {
          return MaterialPageRoute(builder: (_) {
            return UserProfile(args);
          });
        }
        return _errorRoute();

      case RouteConstants.wishlists:
        return MaterialPageRoute(builder: (_) {
          return WishListsScreen();
        });
      case RouteConstants.priceInput:
        return MaterialPageRoute(builder: (_) {
          return ProductPriceInputScreen();
        });
      case RouteConstants.productImageViewer:
        return MaterialPageRoute(builder: (_) {
          return ProductImageViewer((args as Map)['index'], (args)['images']);
        });

      // case RouteConstants.privacy:
      //   return MaterialPageRoute(builder: (_) {
      //     return ChatScreen();
      //   });
      default:
        return MaterialPageRoute(builder: (_) => Container());
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('Error'),
              ),
            ));
  }
}
