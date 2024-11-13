// ignore_for_file: unnecessary_import, use_build_context_synchronously, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
// import 'package:elk/network/entity/user_entity.dart';
import 'package:elk/presentation/elkchat/chat_screen.dart';
// import 'package:elk/presentation/elkchat/chat_screen2.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class ContactWidgetDialog extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> ad;
  const ContactWidgetDialog({
    required this.userId,
    super.key,
    required this.ad,
  });

  @override
  State<StatefulWidget> createState() {
    return _ContactWidgetState();
  }
}

class _ContactWidgetState extends State<ContactWidgetDialog> {
  ApiClient apiClient = GetIt.I<ApiClient>();

  Future<DataSet<Map>>? future;
  // bool isLoadingChat = false;

  @override
  void initState() {
    super.initState();
    future = apiClient.viewContact(widget.userId);
  }

  // Future<Map<String, dynamic>?> fetchUserData(int userId) async {
  //   try {
  //     final DataSet<UserEntity> userDataSet = await apiClient.getUser(userId);
  //     if (userDataSet.success && userDataSet.data != null) {
  //       return userDataSet.data!.toMap();
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<DataSet<Map>>(
          future: future,
          builder: (context, snaShot) {
            if (snaShot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  width: 30,
                  height: 30,
                  child: Center(
                      child: Center(child: CircularProgressIndicator())));
            } else if (snaShot.hasData && snaShot.data!.success) {
              FirebaseFirestore chatFireStore = FirebaseFirestore.instance;
              final userDoc = chatFireStore
                  .collection('privacy')
                  .doc(snaShot.data!.data!['user_id'].toString());
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

              return FutureBuilder(
                future: getPrivacy(),
                builder: (context, snapshot) {
                  bool privacy =
                      snapshot.hasData ? snapshot.data ?? true : true;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      ClipOval(
                        child: snaShot.data!.data!['profile'] == null
                            ? Image.asset(
                                width: 100,
                                '${StringConstants.imageAssetsPath}/guest.png')
                            : CachedNetworkImage(
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: Image.asset(
                                      width: 30,
                                      '${StringConstants.imageAssetsPath}/guest.png'),
                                ),
                                width: 100,
                                height: 100,
                                imageUrl: snaShot.data!.data!['profile'] ?? "",
                              ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(snaShot.data!.data!['name'] ?? ''),
                      const SizedBox(
                        height: 10,
                      ),
                      if (!privacy) ...[
                        Text(snaShot.data!.data!['mobile_number'] ?? ''),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(snaShot.data!.data!['email'] ?? ''),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!privacy) ...[
                            (snaShot.data!.data!['mobile_number'] != null)
                                ? IconButton(
                                    onPressed: () {
                                      launchPhone(
                                          snaShot.data!.data!['mobile_number']);
                                    },
                                    icon: const Icon(Icons.phone))
                                : const SizedBox(),
                            (snaShot.data!.data!['email'] != null)
                                ? IconButton(
                                    onPressed: () {
                                      launchMail(snaShot.data!.data!['email']);
                                    },
                                    icon: const Icon(Icons.email),
                                  )
                                : const SizedBox(),
                          ],
                          // isLoadingChat
                          //     ? const SizedBox(
                          //         width: 24,
                          //         height: 24,
                          //         child: CircularProgressIndicator())
                          // :
                          IconButton(
                            onPressed: () async {
                              // setState(() {
                              //   isLoadingChat = true;
                              // });
                              // Map<String, dynamic>? userData =
                              //     await fetchUserData(widget.userId);
                              // Map<String, dynamic>? authUserData =
                              //     await fetchUserData(
                              //         snaShot.data!.data!['authUserId']);
                              // setState(() {
                              //   isLoadingChat = false;
                              // });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userId: widget.userId,
                                    authUserId:
                                        snaShot.data!.data!['authUserId'],
                                    // userdetails: {
                                    //   "user1": userData,
                                    //   "user2": authUserData
                                    // },
                                    ad: widget.ad,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat),
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            } else {
              return Text(snaShot.data!.message ?? '');
            }
          },
        ),
      ),
    );
  }
}
