// ignore_for_file: unused_import, unnecessary_import, avoid_print, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/presentation/pages/privacy_update_screen.dart';
import 'package:elk/presentation/pages/terms_and_conditions.dart';
import 'package:elk/presentation/pages/terms_page.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/push_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountState();
}

class _AccountState extends State<AccountScreen> {
  // Future<void> deleteAccount(String token, String userId) async {
  //   final url = Uri.parse(
  //       'http://api.elkcompany.online/api/delete_account?user_id=$userId');
  //   try {
  //     final response = await http.delete(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['success']) {

  //       } else {
  //         Fluttertoast.showToast(msg: 'Something went wrong. Try again.');
  //       }
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error deleting account: $error');
  //   }
  // }
  ApiClient apiClient = GetIt.I<ApiClient>();
  bool isDeleting = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(builder: (context, provider, child) {
      return SafeArea(
          child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    user(provider.authUser!),
                    header(Icons.notifications,
                        localisation(context).notification),
                    listButton(
                        'switch', localisation(context).appNotification, () {}),
                    header(Icons.more_vert_sharp, localisation(context).more),
                    listButton('button', localisation(context).changeLanguage,
                        () {
                      Navigator.pushNamed(context, RouteConstants.language,
                          arguments: false);
                    }),
                    listButton('button', localisation(context).privacyPolicy,
                        () async {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const TermsAndConditionsPage();
                      }));
                    }),
                    listButton(
                        'button', localisation(context).termsAndCondition, () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const TermsAndConditionsScreen();
                      }));
                    }),
                    listButton('text', localisation(context).deleteAccount, () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                Text('${localisation(context).deleteAccount}?'),
                            content: const Text(
                                "This action will permanently delete your account, including all your data and preferences. This action cannot be undone. Are you sure you want to proceed?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    isDeleting = true;
                                  });
                                  final success = await apiClient
                                      .deleteAccount(provider.authUser?.userId);
                                  setState(() {
                                    isDeleting = false;
                                  });
                                  if (success) {
                                    await AppPrefrences.clearUser()
                                        .then((value) {
                                      Fluttertoast.showToast(
                                          msg: 'Deleted Successfully.');
                                      context
                                          .read<AppAuthProvider>()
                                          .isSignedIn();
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Something went wrong. Please try again later.$success');
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    }),
                    listButton('text', localisation(context).signOut, () async {
                      await AppPrefrences.clearUser().then((value) {
                        Fluttertoast.showToast(msg: 'Signout successfully');
                        context.read<AppAuthProvider>().isSignedIn();
                      });
                    })
                  ],
                ),
              ),
            ),
            if (isDeleting)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ));
    });
  }

  Widget user(AuthUser? authUser) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content:
                        (authUser.profile != null && authUser.profile != '')
                            ? CachedNetworkImage(
                                imageUrl: authUser.profile!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: Image.asset(
                                    width: 30,
                                    '${StringConstants.imageAssetsPath}/guest.png'),
                              ),
                  );
                },
              );
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: ClipOval(
                child: (authUser!.profile != null && authUser.profile != '')
                    ? CachedNetworkImage(
                        imageUrl: authUser.profile!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Image.asset(
                            width: 30,
                            '${StringConstants.imageAssetsPath}/guest.png'),
                      ),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                authUser.userType == UserType.user
                    ? authUser.name ?? 'user_name'
                    : 'Guest user',
                style: Theme.of(context).textTheme.bodyLarge,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                authUser.userType == UserType.user
                    ? authUser.mobile ?? authUser.email!
                    : '',
              )),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
            child: Divider(
              height: 0,
              color: Colors.grey.shade300,
            ),
          ),
          header(Icons.usb_rounded, localisation(context).account),
          listButton('button', localisation(context).editProfile, () {
            if (authUser.userType == UserType.user) {
              Navigator.pushNamed(context, RouteConstants.profileScreen);
            } else {
              Fluttertoast.showToast(
                  msg: 'Guest user cannot access this option');
            }
          }),
          listButton('button', localisation(context).wishlist, () {
            if (authUser.userType == UserType.user) {
              Navigator.pushNamed(context, RouteConstants.wishlists);
            } else {
              Fluttertoast.showToast(
                  msg: 'Guest user cannot access this option');
            }
          }),
          listButton(
            'button',
            localisation(context).privacy,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PrivacyUpdate(authUser: authUser),
                ),
              );
            },
          )
          // listButtonPrivacySwitch('Privacy', authUser),
        ],
      ),
    );
  }

  Widget header(IconData iconData, String title) {
    return Ink(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircleAvatar(
              backgroundColor: Constants.primaryColor.withOpacity(0.7),
              foregroundColor: Colors.white,
              child: Icon(
                iconData,
                size: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget listButton(String type, String label, Function() onTap) {
    return FutureBuilder<bool?>(
      future: AppPrefrences.getNotification(),
      builder: (context, snapShot) {
        bool enabled = snapShot.hasData ? snapShot.data ?? false : false;
        return StatefulBuilder(
          builder: (context, statefulState) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: type == 'switch' ? null : onTap,
                child: Ink(
                  padding: const EdgeInsets.only(
                      left: 23, right: 23, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      if (type == 'button')
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      if (type == 'switch')
                        Transform.scale(
                          scale: 0.7,
                          child: Switch(
                            activeColor: const Color(0xFF4Fbbb4),
                            value: enabled,
                            onChanged: (val) async {
                              if (val) {
                                statefulState(
                                  () {
                                    enabled = !enabled;
                                  },
                                );
                                await notificationRequest().then(
                                  (value) async {
                                    if (value.isGranted) {
                                      await FirebasePush.enableToken();
                                      Fluttertoast.showToast(
                                          msg: 'Now App notification is on');
                                    } else {
                                      openAppSettings();
                                      Fluttertoast.showToast(
                                          msg:
                                              'Enable notification permission');
                                      statefulState(
                                        () {
                                          enabled = !enabled;
                                        },
                                      );
                                    }
                                  },
                                );
                              } else {
                                FirebasePush.deleteToken();
                                AppPrefrences.setNotification(false);
                                statefulState(
                                  () {
                                    enabled = !enabled;
                                  },
                                );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget listButtonPrivacySwitch(String label, AuthUser? authUser) {
    FirebaseFirestore chatFireStore = FirebaseFirestore.instance;
    final userDoc =
        chatFireStore.collection('privacy').doc(authUser?.userId.toString());
    Future<bool> getPrivacy() async {
      try {
        final docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          final privacy = docSnapshot.get('privacy');
          return privacy;
        } else {
          return true;
        }
      } catch (e) {
        return true;
      }
    }

    return FutureBuilder<bool?>(
      future: getPrivacy(),
      builder: (context, snapShot) {
        bool privacy = (authUser?.userType == UserType.guest)
            ? false
            : snapShot.hasData
                ? snapShot.data ?? true
                : true;
        return StatefulBuilder(builder: (context, statefulState) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              child: Ink(
                padding: const EdgeInsets.only(
                    left: 23, right: 23, top: 15, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: privacy,
                        onChanged: (authUser?.userType == UserType.guest)
                            ? (value) {
                                Fluttertoast.showToast(
                                  msg: 'Guest user cannot access this option',
                                );
                              }
                            : (value) async {
                                statefulState(
                                  () {
                                    privacy = !privacy;
                                  },
                                );
                                try {
                                  final docSnapshot = await userDoc.get();
                                  if (docSnapshot.exists) {
                                    await userDoc.update({
                                      'privacy': privacy,
                                      'name': authUser?.name,
                                      'userid': authUser?.userId
                                    });
                                  } else {
                                    await userDoc.set({
                                      'privacy': privacy,
                                      'name': authUser?.name,
                                      'userid': authUser?.userId
                                    });
                                  }

                                  if (value) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your contacts are now hidden from others.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Your contacts are now visible to others.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Failed to update privacy setting: $e",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
