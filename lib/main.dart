// ignore_for_file: unused_import, unnecessary_import, unused_local_variable

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:elk/bloc/chat_room_list/chat_room_list_bloc.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/bloc/language_selection_bloc.dart';
import 'package:elk/bloc/myads_bloc.dart';
import 'package:elk/bloc/otp_screen_bloc.dart';
import 'package:elk/config/route_generator.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/firebase_options.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/presentation/chat/widgets/message_input.dart';
import 'package:elk/presentation/elkchat/chat_screen/chat_screen_bloc.dart';
import 'package:elk/presentation/elkchat/message_input/message_input_bloc.dart';
import 'package:elk/presentation/pages/account_screen.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/presentation/pages/dashboard_screen.dart';
import 'package:elk/presentation/pages/language_selection_screen.dart';
import 'package:elk/presentation/pages/login_screen.dart';
import 'package:elk/presentation/pages/otp_screen.dart';
import 'package:elk/presentation/pages/splash_screen.dart';
import 'package:elk/config/theme.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/success_page.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/language_changer.dart';
import 'package:elk/utils/local_notification.dart';
import 'package:elk/utils/push_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();

  void setUp() {
    final getIt = GetIt.instance;
    getIt.registerSingleton(
      ApiClient(
        baseUrl: StringConstants.baseUrl,
        apiKey: dotenv.env['API_KEY']!,
      ),
    );
  }

  setUp();
  FirebaseMessaging.onBackgroundMessage(FirebasePush.backgroundMessageHandler);
  FirebaseMessaging.onMessage.listen(FirebasePush.inAppMessageHandler);
  final AppAuthProvider appAuthProvider;

  //Local
  await LocalNotification.initializeNotification();
  FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
    FirebasePush.subScribeToTopic('General');
    await GetIt.I<ApiClient>().updateNotificationToken(event);
    AppPrefrences.setNotification(true);
  });
  runApp(const MyApp());
}

AppLanguageNotifier appLanguageNotifier = AppLanguageNotifier();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppSatte();
  }
}

class _MyAppSatte extends State<MyApp> {
  AppAuthProvider authProvider(BuildContext context) {
    return AppAuthProvider(RepositoryProvider.of<UserRepository>(context));
  }

  @override
  Widget build(BuildContext context) {
    return multiRepository(
        child: multiBloc(
            child: ListenableBuilder(
      listenable: appLanguageNotifier,
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => AppAuthProvider(
          RepositoryProvider.of<UserRepository>(context, listen: false),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleFactor(context))),
          child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: lightTheme,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('hi'),
                Locale('ml')
              ],
              locale: appLanguageNotifier.currentLanguage,
              onGenerateRoute: RouteGenerator.authenicatedRoutes,
              home: const AuthControllerWidget()),
        ),
      ),
    )));
  }

  Widget multiRepository({required Widget child}) {
    return MultiRepositoryProvider(
      providers: [
        _useRepositoryProvider(),
        _placeRepositoryProvider(),
        _locatipnRepository(),
        _rentAdsRepo(),
      ],
      child: child,
    );
  }

  Widget multiBloc({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => LocationCubit(
                locationRepository:
                    RepositoryProvider.of<LocationRepository>(context))),
        BlocProvider(
            create: (context) =>
                MyAdsBloc(RepositoryProvider.of<RentAdsRepository>(context))),
        BlocProvider(
            create: (_) => MessageInputBloc(navigatorKey, isAdTag: false)),
        BlocProvider(
          create: (_) => ChatScreenBloc(),
        ),
        BlocProvider(
          create: (_) => ChatRoomListBloc(
              authUserId: authProvider(context).authUser!.userId),
        )
      ],
      child: child,
    );
  }

  /*  Widget authprovider(UserRepository userRepository,
      Widget Function(BuildContext context, Widget? child) builder) {
    return Provider(
        create: (context) => AppAuthProvider(userRepository), builder: builder);
  } */

  RepositoryProvider<UserRepository> _useRepositoryProvider() {
    return RepositoryProvider<UserRepository>(create: (_) => UserRepository());
  }

  RepositoryProvider<PlaceRepository> _placeRepositoryProvider() {
    return RepositoryProvider<PlaceRepository>(
        create: (_) => PlaceRepository());
  }

  RepositoryProvider<LocationRepository> _locatipnRepository() {
    return RepositoryProvider<LocationRepository>(
        create: (_) => LocationRepository());
  }

  RepositoryProvider<RentAdsRepository> _rentAdsRepo() {
    return RepositoryProvider<RentAdsRepository>(
        create: (_) => RentAdsRepository());
  }
}

class AuthControllerWidget extends StatelessWidget {
  const AuthControllerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppAuthProvider>(context, listen: false);
    return Builder(builder: (context) {
      return StreamBuilder(
        stream: provider.authStram,
        builder: (context, snapShot) {
          debugPrint('Auth user changed');
          if (Provider.of<AppAuthProvider>(context, listen: false).authUser !=
              null) {
            GetIt.I<ApiClient>().updateApikey(
                Provider.of<AppAuthProvider>(context, listen: false)
                    .authUser!
                    .token);
          }
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapShot.hasData && snapShot.data!) {
            // return const AccountScreen();
            return const DashBoardScreen();
          } else {
            return LanguageSelectionScreen(
              isInitialPage: true,
              languageSelectionBloc: LanguageSelectionBloc(),
            );
          }
        },
      );
    });
  }
}
