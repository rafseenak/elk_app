// ignore_for_file: unused_import, sized_box_for_whitespace

import 'dart:async';
import 'package:either_dart/either.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/bloc/event/login_screen_event.dart';
import 'package:elk/bloc/state/login_screen_state.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/shared/loading_Dialog.dart';
import 'package:elk/presentation/widgets/common_button.dart';
import 'package:elk/presentation/widgets/divider_text.dart';
import 'package:elk/constants/sizes.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/presentation/widgets/loading_button.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ValueNotifier<String> _mobileNoListenable = ValueNotifier('');
  final _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> guestSignIn() async {
    loadingDialog(context);
    await Provider.of<AppAuthProvider>(context, listen: false)
        .guestSignIn()
        .then((value) {
      if (value.success) {
        Fluttertoast.showToast(msg: 'Login Success!');
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: value.message ?? '');
      }
    });
  }

  Future<void> googleSign() async {
    loadingDialog(context);
    await Provider.of<AppAuthProvider>(context, listen: false)
        .googleSignin()
        .then((value) {
      if (value.success) {
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: value.message ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginScreenBloc, LoginScreenState>(
      builder: (context, loginState) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      surfaceTintColor: Colors.red,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      minimumSize: Size.zero),
                  onPressed: () {
                    guestSignIn();
                  },
                  child: Text(localisation(context).skip)),
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 100,
                left: canvasPadding,
                right: canvasPadding,
                bottom: 20),
            child: Column(children: [
              const SizedBox(
                height: 80,
              ),
              Center(
                  child: Image.asset(
                '${StringConstants.imageAssetsPath}/logo.png',
                width: 200,
              )),
              Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    localisation(context).yourBusinessHub,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: dividerText(localisation(context).loginOrSignUp),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                child: Stack(
                  children: [
                    TextField(
                      focusNode: _focusNode,
                      onSubmitted: (value) => FocusScope.of(context).unfocus(),
                      controller: _textEditingController,
                      onChanged: (value) {
                        debugPrint('mobile No: $value');
                        _mobileNoListenable.value = value;
                      },
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: _focusNode.hasFocus ||
                                _textEditingController.text.isNotEmpty
                            ? ''
                            : localisation(context).enterPhoneNumber,
                        border: InputBorder.none,
                      ),
                    ),
                    Positioned(
                      top: 15,
                      child: Container(
                        width: 100,
                        child: const Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _mobileNoListenable,
                  builder: (context, mobileNo, child) => loginState.otpIsSending
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: loadingButton())
                      : commonButton(localisation(context).sendOtp,
                          onTap: mobileNo.length == 10
                              ? () async {
                                  FocusScope.of(context).unfocus();
                                  context
                                      .read<LoginScreenBloc>()
                                      .add(OTPsending());
                                  await context
                                      .read<AppAuthProvider>()
                                      .sendOtp(
                                        '+91 ${_textEditingController.value.text}',
                                      )
                                      .then((value) => {
                                            if (value.success)
                                              {
                                                context
                                                    .read<LoginScreenBloc>()
                                                    .add(OTPsended()),
                                                Navigator.pushNamed(
                                                    context, RouteConstants.otp,
                                                    arguments: {
                                                      'phoneNumber':
                                                          '+91 ${_textEditingController.value.text}',
                                                      'verificationId':
                                                          value.data![
                                                              'verificationId'],
                                                    })
                                              }
                                            else
                                              {
                                                {
                                                  Fluttertoast.showToast(
                                                      msg: value.message!),
                                                  context
                                                      .read<LoginScreenBloc>()
                                                      .add(OTPSendingFailed())
                                                }
                                              }
                                          });
                                }
                              : null)),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: dividerText(localisation(context).or),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0XFFF4F4F4),
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
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
                                .copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w600),
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
                        googleSign();
                      }),
                    ))
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
