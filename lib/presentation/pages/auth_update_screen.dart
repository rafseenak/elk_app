// ignore_for_file: unused_import, library_prefixes, unnecessary_import, duplicate_import

import 'package:elk/constants/stringss.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/model/auth_user.dart';
import 'package:elk/data/model/user_model.dart' as profileUser;
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/client/api_client.dart';
import 'package:elk/presentation/widgets/common_button.dart';
import 'package:elk/presentation/widgets/loading_button.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/provider/profile_provider.dart';
import 'package:elk/shared/loading_dialog.dart';
import 'package:elk/utils/app_preferences.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';

class AuthUpdateScreen extends StatefulWidget {
  final ProfileProvider profileProvider;
  final String authType;
  final String? value;

  const AuthUpdateScreen(
      {super.key,
      required this.profileProvider,
      required this.authType,
      this.value});

  @override
  State<StatefulWidget> createState() {
    return _AuthUpdateScreen();
  }
}

class _AuthUpdateScreen extends State<AuthUpdateScreen> {
  bool otpSending = false;
  bool otpSended = false;
  String? verificationid;
  int? resendToken;
  String? otp;
  final otpEditTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOtp(String mobileNumber) async {
    final apiClient = GetIt.I<ApiClient>();
    apiClient.sendOtp(mobileNumber).then((value) {
      if (value.success) {
        setState(() {
          verificationid = value.data!['verificationId'];
          otpSended = true;
          otpSending = false;
        });
      }
    });
  }

  Future<DataSet<String>> verifyPhoneNumber(
      ProfileProvider profileProvider, String mobile, String otp) async {
    final apiClient = GetIt.I<ApiClient>();
    final res =
        await apiClient.verifyUpdateMobile(verificationid!, int.parse(otp));

    if (res.success) {
      final res = await profileProvider.updateMobileOrEmail('mobile', mobile);
      if (res.success) {
        return res;
      } else {
        return res;
      }
    } else {
      return DataSet.error('Something went wrong');
    }
  }

  Future<DataSet<String>> googleSignin(ProfileProvider profileProvider) async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential data = await _auth.signInWithCredential(credential);
      User? user = data.user;
      if (user != null) {
        final res = await profileProvider
            .updateMobileOrEmail('email', user.email!, uid: user.uid);
        if (res.success) {
          /* profileUser.User  newData = profileUser.User.; 
          AppPrefrences.setUser(profileProvider.user, UserType.user); */
          return res;
        } else {
          return res;
        }
      } else {
        return DataSet.error('Something went wrong');
      }
    } on PlatformException catch (e) {
      if (e.code == 'network_error') {
        debugPrint('Google sign network error');
        return DataSet.error('Connection error');
      } else {
        debugPrint('Error signing in with Google: $e');
        return DataSet.error(e.toString());
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return DataSet.error('Something went wrong');
    }
  }

  ApiClient apiClient = GetIt.I<ApiClient>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(),
        body: ChangeNotifierProvider.value(
          value: widget.profileProvider,
          child: Consumer<ProfileProvider>(builder: (context, state, child) {
            return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    if (widget.authType == 'mobile') ...[
                      textField(context),
                      if (otpSended) otpField(state),
                      otpButton(state)
                    ] else ...[
                      googleButton(state)
                    ]
                  ],
                ));
          }),
        ));
  }

  AppBar appBar() {
    String title = (widget.authType == 'mobile' &&
            widget.value != null &&
            widget.value != '')
        ? 'Add new mobile number'
        : (widget.authType == 'mobile' && widget.value == null ||
                widget.value == '')
            ? 'Add mobile number'
            : (widget.authType == 'email' &&
                    widget.value != null &&
                    widget.value != '')
                ? 'Add new email'
                : 'Add email';
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0.5,
      shadowColor: Colors.grey,
    );
  }

  Widget textField(BuildContext context) {
    String labeltext = (widget.authType == 'mobile' &&
            widget.value != null &&
            widget.value != '')
        ? 'New mobile'
        : 'Mobile';

    return SizedBox(
      width: double.infinity,
      child: TextField(
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        enabled: (otpSending || otpSended) ? false : true,
        controller: otpEditTextController,
        keyboardType: widget.authType == 'mobile'
            ? TextInputType.phone
            : TextInputType.emailAddress,
        onTapOutside: (e) {
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
            hintStyle: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            labelStyle: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(15),
              child: Text('+91'),
            ),
            labelText: labeltext,
            border: const OutlineInputBorder()),
      ),
    );
  }

  Widget otpField(ProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: OtpPinField(
          fieldWidth: 40,
          otpPinFieldStyle: const OtpPinFieldStyle(fieldBorderRadius: 5),
          otpPinFieldDecoration: OtpPinFieldDecoration.custom,
          maxLength: 6,
          onSubmit: (value) {
            otp = value;
          },
          onChange: (value) {
            otp = value;
          }),
    );
  }

  Widget otpButton(ProfileProvider profileProvider) {
    return Builder(builder: (context) {
      if (otpSending) {
        return Padding(
            padding: const EdgeInsets.only(top: 20), child: loadingButton());
      }
      return commonButton(!otpSended ? 'send OTP' : 'Verify OTP',
          onTap: () async {
        FocusScope.of(context).unfocus();
        if (!otpSended) {
          if (otpEditTextController.value.text.length == 10) {
            apiClient
                .checkPhoneExists('+91 ${otpEditTextController.value.text}')
                .then((isPhoneExist) async {
              if (!isPhoneExist) {
                setState(() {
                  otpSending = true;
                });
                sendOtp('+91 ${otpEditTextController.value.text}');
              } else {
                Fluttertoast.showToast(
                    msg:
                        'An account already exists with the given number. Please try again with a different number.');
              }
            });
          } else {
            Fluttertoast.showToast(msg: 'Invalid mobile number');
          }
        } else {
          if (otp == null || otp!.length < 6) {
            Fluttertoast.showToast(msg: 'Otp invalid');
          } else {
            setState(() {
              otpSending = true;
            });
            await verifyPhoneNumber(profileProvider,
                    '+91 ${otpEditTextController.value.text}', otp!)
                .then((value) {
              if (value.success) {
                Fluttertoast.showToast(msg: 'Mobile number updated');
                Navigator.pop(context, true);
              } else {
                setState(() {
                  otpSending = false;
                });
              }
            });
          }
        }
      });
    });
  }

  Widget googleButton(ProfileProvider profileProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0XFFF4F4F4),
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: Stack(
              children: [
                Image.asset(
                  '${StringConstants.imageAssetsPath}/google.png',
                  width: 30,
                ),
                Positioned.fill(
                    child: Center(
                        child: Text(
                  localisation(context).continueWithGoogle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                )))
              ],
            ),
          ),
          Positioned.fill(
              child: Material(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(10),
            color: Colors.transparent,
            child: InkWell(onTap: () async {
              loadingDialog(context);
              googleSignin(profileProvider).then((value) {
                if (value.success) {
                  Fluttertoast.showToast(msg: 'Email updated successfully');
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: value.message!);
                }
              });
            }),
          ))
        ],
      ),
    );
  }
}
