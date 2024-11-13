import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PrivacyUpdate extends StatelessWidget {
  final AuthUser authUser;
  const PrivacyUpdate({
    super.key,
    required this.authUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        children: [
          listButtonPrivacySwitch(localisation(context).privacy, authUser)
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: Text(localisation(context).privacyUpdateScreen),
      centerTitle: true,
      leading: BackButton(
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
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
