// ignore_for_file: unused_import

import 'dart:async';

import 'package:elk/bloc/event/login_screen_event.dart';
import 'package:elk/bloc/event/otp_screen_event.dart';
import 'package:elk/bloc/login_screen_bloc.dart';
import 'package:elk/bloc/otp_screen_bloc.dart';
import 'package:elk/bloc/state/otp_screen_state.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/main.dart';
import 'package:elk/presentation/widgets/loading_button.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/presentation/widgets/border_button.dart';
import 'package:elk/presentation/widgets/common_button.dart';
import 'package:elk/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  final OTPSreenBloc otpScreenBloc;
  const OTPScreen({super.key, required this.otpScreenBloc});
  @override
  State<OTPScreen> createState() {
    return _OTPScreenState();
  }
}

class _OTPScreenState extends State<OTPScreen> {
  late final OTPSreenBloc otpScreenBloc = widget.otpScreenBloc;
  final otpSendingValueNotifier = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    otpScreenBloc.add(ResendTimerStart(0));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Otp screen rendered');

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 20, left: canvasPadding, right: canvasPadding, bottom: 20),
        child: Column(children: [
          Center(
            child: Text(
              'Verification Code',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                '''Please enter the verification code\n sent to  ${otpScreenBloc.phoneNumber}''',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(height: 1.5),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 30),
              child: OtpPinField(
                fieldWidth: 40,
                maxLength: 6,
                otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                otpPinFieldStyle: const OtpPinFieldStyle(
                    fieldBorderRadius: 10,
                    defaultFieldBorderColor: Color(0XFFDBDEE4),
                    filledFieldBorderColor: Colors.black,
                    fieldBorderWidth: 0.2),
                onChange: (String text) {
                  otpScreenBloc.add(AddOtp(text));
                },
                onSubmit: (String text) {
                  otpScreenBloc.add(AddOtp(text));
                },
              )),
          const Spacer(),
          BlocBuilder<OTPSreenBloc, OTPScreenState>(
              bloc: otpScreenBloc,
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.duration > 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Resend available in ${state.duration} seconds',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.purple),
                        ),
                      ),
                    borderButton(
                      'Resend',
                      enabled: state.duration > 0 ? false : true,
                      margin: const EdgeInsets.only(bottom: 0),
                      onTap: state.duration <= 0
                          ? () async {
                              await context
                                  .read<AppAuthProvider>()
                                  .sendOtp(otpScreenBloc.phoneNumber)
                                  .then((value) {
                                if (value.success) {
                                  otpScreenBloc.add(UpdateVerificationId(
                                      verificationId:
                                          value.data!['verificationId']));
                                } else {
                                  Fluttertoast.showToast(msg: value.message!);
                                  context
                                      .read<LoginScreenBloc>()
                                      .add(OTPSendingFailed());
                                }
                              });
                              otpScreenBloc.add(ResendOtp(timer: 60));
                            }
                          : null,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: otpSendingValueNotifier,
                        builder: (context, otpSending, child) => otpSending
                            ? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: loadingButton(),
                              )
                            : commonButton('Submit',
                                enabled: true,
                                onTap: state.otp.length == 6
                                    ? () async {
                                        otpSendingValueNotifier.value = true;
                                        await Provider.of<AppAuthProvider>(
                                                context,
                                                listen: false)
                                            .verifyOtp(state.verificationId,
                                                int.parse(state.otp))
                                            .then((value) {
                                          if (value.success) {
                                            Fluttertoast.showToast(
                                                msg: 'Login success');
                                            while (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: value.message!);
                                          }
                                        });
                                        otpSendingValueNotifier.value = false;
                                      }
                                    : null))
                  ],
                );
              }),
        ]),
      ),
    );
  }
}
