// ignore_for_file: unused_import, unnecessary_import, deprecated_member_use, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/provider/profile_provider.dart';
import 'package:elk/shared/profile_complete_dialog.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends StatelessWidget {
  final bool updateRequired;
  ProfileScreen({super.key, required this.updateRequired});
  final ValueNotifier<bool> imageUploadNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final appAuthProvider = Provider.of<AppAuthProvider>(context, listen: true);
    return ChangeNotifierProvider<ProfileProvider>(
        create: (context) => ProfileProvider(appAuthProvider,
            userRepository: RepositoryProvider.of<UserRepository>(context)),
        child: Consumer<ProfileProvider>(builder: (context, state, child) {
          return WillPopScope(
            onWillPop: () async {
              if (updateRequired) {
                if ((appAuthProvider.authUser!.name != null ||
                        appAuthProvider.authUser!.name != '') ||
                    (appAuthProvider.authUser!.email != null ||
                        appAuthProvider.authUser!.email != '') ||
                    appAuthProvider.authUser!.mobile != null ||
                    appAuthProvider.authUser!.mobile != '') {
                  await showDialog(
                          context: context,
                          builder: (context) => const ProfileCompleteDialog())
                      .then((value) {
                    if (value != null && value == false) {
                      Navigator.pop(context);
                    }
                  });
                }

                return false;
              }
              return true;
            },
            child: Scaffold(
              appBar: appBar(context, appAuthProvider),
              body: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: dp(context, state),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: name(context, state.user!.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: description(context, state.user!.decription),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RouteConstants.profileUpdate,
                                  arguments: state);
                            },
                            child: Text(
                              localisation(context).updateProfile,
                              style: const TextStyle(color: Color(0xFF4Fbbb4)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: textField(
                              context,
                              state,
                              localisation(context).email,
                              state.user!.email ?? ''),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: textField(context, state,
                              localisation(context).mobile, state.user!.mobile),
                        )
                      ]),
                    ),
            ),
          );
        }));
  }

  AppBar appBar(BuildContext context, AppAuthProvider appAuthProvider) {
    return AppBar(
      title: Text(localisation(context).editProfile),
      centerTitle: true,
      leading: BackButton(
        onPressed: () async {
          if ((appAuthProvider.authUser!.name != null ||
                  appAuthProvider.authUser!.name != '') ||
              (appAuthProvider.authUser!.email != null ||
                  appAuthProvider.authUser!.email != '') ||
              appAuthProvider.authUser!.mobile != null ||
              appAuthProvider.authUser!.mobile != '') {
            await showDialog(
                    context: context,
                    builder: (context) => const ProfileCompleteDialog())
                .then((value) {
              if (value != null && value == false) {
                while (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // Navigator.pop(context);
              }
            });
          }
        },
      ),
    );
  }

  Widget dp(BuildContext context, ProfileProvider provider) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: GestureDetector(
          onTap: () async {
            final image = await selectImage();

            if (image != null) {
              final croppedFile = await ImageCropper().cropImage(
                sourcePath: image,
                uiSettings: [
                  AndroidUiSettings(
                      toolbarTitle: 'Crop',
                      toolbarColor: Theme.of(context).primaryColor,
                      toolbarWidgetColor: Colors.white,
                      lockAspectRatio: true,
                      initAspectRatio: CropAspectRatioPreset.square,
                      hideBottomControls: true,
                      showCropGrid: false),
                  IOSUiSettings(
                    title: 'Cropper',
                    aspectRatioLockEnabled: true,
                    aspectRatioPresets: [
                      CropAspectRatioPresetCustom(),
                    ],
                  ),
                ],
              );
              if (croppedFile != null) {
                imageUploadNotifier.value = true;
                final res = await provider.uploadProfilePic(croppedFile.path);
                if (res.success) {
                  Fluttertoast.showToast(
                    msg: "Profile Updated Successfully.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.pushReplacementNamed(
                    context,
                    RouteConstants.profileScreen,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Error Occured while updating profile pic.}",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
                imageUploadNotifier.value = false;
              }
            }
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300)),
                  child: ClipOval(
                    child: (provider.user!.profile != null &&
                            provider.user!.profile != '')
                        ? CachedNetworkImage(
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(),
                            imageUrl: provider.user!.profile!,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Image.asset(
                              width: 30,
                              '${StringConstants.imageAssetsPath}/guest.png',
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 20,
                  right: 15,
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      color: Colors.black,
                      child: const Icon(
                        Icons.edit,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  )),
              Positioned.fill(
                  child: ValueListenableBuilder(
                      valueListenable: imageUploadNotifier,
                      builder: (context, loading, child) => loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox()))
            ],
          ),
        ),
      ),
    );
  }

  Widget name(BuildContext context, String? name) {
    return Text(
      name == null || name == '' ? localisation(context).name : name,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),
    );
  }

  Widget description(BuildContext context, String? description) {
    return Text(
      description ?? localisation(context).description,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
    );
  }

  Widget textField(BuildContext context, ProfileProvider profileProvider,
      String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.only(left: 10, right: 10),
          margin: const EdgeInsets.only(top: 5),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(value ?? ''),
            FilledButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(0, 0)),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 10),
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.amber),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: () {
                  if (label == 'Mobile') {
                    Navigator.pushNamed(context, RouteConstants.authUpdate,
                        arguments: {
                          'profileProvider': profileProvider,
                          'authType': 'mobile',
                          'authValue': profileProvider.user!.mobile
                        });
                  } else {
                    Navigator.pushNamed(context, RouteConstants.authUpdate,
                        arguments: {
                          'profileProvider': profileProvider,
                          'authType': 'email',
                          'authValue': profileProvider.user!.mobile
                        });
                  }
                },
                child: Text(
                  (value == null || value == '')
                      ? localisation(context).add
                      : localisation(context).change,
                ))
          ]),
        )
      ],
    );
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (1, 1);

  @override
  String get name => '1x1 (customized)';
}
