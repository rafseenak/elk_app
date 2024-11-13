// ignore_for_file: unused_import, non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/cubit/ad_post_state.dart';
import 'package:elk/data/model/price_details.dart';
import 'package:elk/presentation/pages/product_price_input.dart';
import 'package:elk/presentation/widgets/price_detial_widget.dart';
import 'package:elk/provider/auth_provider.dart';
import 'package:elk/shared/loading_dialog.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:provider/provider.dart';

class AdPostStage1 extends StatefulWidget {
  final String? adType;
  final String? title;
  final String? category;
  final AdPostCubit adPostCubit;
  const AdPostStage1(this.adType, this.title, this.category, this.adPostCubit,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdpostStaeg1State();
  }
}

class _AdpostStaeg1State extends State<AdPostStage1> {
  String CategotyTitle = '';
  final data = ["Per hour", "Per day", "Per week", "Per Month"];
  final ValueNotifier<List<Map<String, dynamic>>> selectedlist =
      ValueNotifier([]);
  final ValueNotifier<int> priceWidgets = ValueNotifier(1);
  late final AppAuthProvider authProvider =
      Provider.of<AppAuthProvider>(context);
  final formKey = GlobalKey<FormState>();
  bool priceDetailsError = false;
  bool isPrivacyNotifierShown = false;
  FirebaseFirestore chatFireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    if (widget.adPostCubit.adResponse != null) {
      String category = widget.adPostCubit.adResponse!.category;
      if (category.substring(category.length - 1, category.length) == 's') {
        CategotyTitle = category.substring(0, category.length - 1);
      } else {
        CategotyTitle = category;
      }

      final List<Map<String, dynamic>> priceList = [];
      for (var element in widget.adPostCubit.adResponse!.adPriceDetails) {
        priceList.add(
            {'duration': element.rentDuration, 'price': element.rentPrice});
      }
      selectedlist.value = List.from(priceList);
    }
  }

  bool formValidate() {
    if (widget.adPostCubit.priceDetialsMap.isEmpty) {
      setState(() {
        priceDetailsError = true;
      });
      return false;
    }
    if (formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }

  void deletePriceWidget(int index) {
    final List<Map<String, dynamic>> list = List.from(selectedlist.value);
    list.removeAt(index);
    selectedlist.value = list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostCubit, AdPostState>(
        bloc: widget.adPostCubit,
        builder: (context, state) {
          return Scaffold(
            appBar: appBar(),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 30),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            basicTextField(
                                widget.adPostCubit.adResponse != null
                                    ? widget.adPostCubit.adResponse!.title
                                    : '',
                                TextInputType.text,
                                localisation(context).title,
                                validateAdTitle,
                                widget.adPostCubit.changeTitle),
                            basicTextField(
                                widget.adPostCubit.adResponse != null
                                    ? widget.adPostCubit.adResponse!.description
                                    : '',
                                TextInputType.multiline,
                                localisation(context).description,
                                validateAdDescription,
                                widget.adPostCubit.changeDescription),
                            ValueListenableBuilder(
                                valueListenable: selectedlist,
                                builder: (context, list, child) {
                                  return Column(
                                    children: widget
                                        .adPostCubit.priceDetialsMap.entries
                                        .toList()
                                        .map((e) => priceStateFulWidget(
                                            e.key.toString(),
                                            e.value.toString()))
                                        .toList(),
                                  );
                                }),
                            Padding(
                              padding: const EdgeInsets.only(),
                              child: addMorePriceButton(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Center(
                                  child: priceDetailsError
                                      ? BlinkingText(
                                          text: localisation(context)
                                              .pleaseAddPriceDetails,
                                          duration: const Duration(seconds: 1),
                                        )
                                      : const Text('')
                                  // child: Text(
                                  //   priceDetailsError
                                  //       ? localisation(context)
                                  //           .pleaseAddPriceDetails
                                  //       : '',
                                  //   style: Theme.of(context)
                                  //       .textTheme
                                  //       .bodyMedium!
                                  //       .copyWith(color: Colors.red),
                                  // ),
                                  ),
                            ),
                            contactButton()
                          ],
                        ),
                      )),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      top: 10, left: 20, right: 20, bottom: 30),
                  child: SizedBox(height: 40, child: nextButton()),
                )
              ],
            ),
          );
        });
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            localisation(context).addBasicDetails,
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .copyWith(fontSize: 15),
          ),
          /*  Text(
            '${widget.title ?? CategotyTitle} & ${localisation(context).contactDetails}',
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .copyWith(fontSize: 12),
          ) */
        ],
      ),
      elevation: 1,
    );
  }

  Widget basicTextField(
      String value, TextInputType textType, String hint, validator, onChange) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: TextFormField(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
        initialValue: value,
        minLines: textType == TextInputType.multiline ? 5 : 1,
        maxLines: null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: textType,
        validator: validator,
        onChanged: onChange,
        decoration: InputDecoration(
          hintText: hint,
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget addMorePriceButton() {
    return Center(
        child: TextButton(
      onPressed: () async {
        /* if (selectedlist.value.length < data.length) {
                final List<Map<String, dynamic>> list =
                    List.from(selectedlist.value);
                list.add({});
                selectedlist.value = list;
              } else {
                Fluttertoast.showToast(msg: 'Maximum price allowed');
              } */
        //Navigator.of(context).pushNamed(RouteConstants.priceInput);
        final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            barrierColor: Colors.white,
            builder: (context) => const ProductPriceInputScreen());
        if (result != null) {
          final List<Map<String, dynamic>> list = List.from(selectedlist.value);
          list.add({});
          selectedlist.value = list;
          widget.adPostCubit.addPriceMap(result as PriceDetails);
          priceDetailsError = false;
          setState(() {});
        }
      },
      child: Text(
        localisation(context).addPriceDetials,
        style: const TextStyle(
          color: Color(0xFF4Fbbb4),
        ),
      ),
    ));
  }

  Widget contactButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localisation(context).yourContactDetails),
        Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade300),
            width: double.infinity,
            child: Column(
              children: [
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                  enabled: false,
                  controller: TextEditingController(
                      text: (authProvider.authUser!.mobile != null)
                          ? '+91  ${authProvider.authUser!.mobile}'
                          : '+91 '),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      suffix: const Icon(
                        Icons.lock,
                        size: 17,
                      ),
                      labelText: localisation(context).mobile,
                      border: InputBorder.none),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: TextField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                    enabled: false,
                    controller: TextEditingController(
                      text: (authProvider.authUser!.email != null)
                          ? authProvider.authUser!.email
                          : '',
                    ),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        suffix: const Icon(
                          Icons.lock,
                          size: 17,
                        ),
                        labelText: localisation(context).email,
                        border: InputBorder.none),
                  ),
                ),
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            'You are posting as ${authProvider.authUser!.name}',
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget priceStateFulWidget(String? initialDuration, String? initialPrice) {
    return PriceDetailWidget(initialDuration!, initialPrice!, () {
      widget.adPostCubit.deletePriceMap(initialDuration);
      setState(() {});
      //deletePriceWidget(index);
    }

        //isInitial: index > 0 && index == length - 1 ? false : true,

        /* onDelete: (key) {
        deletePriceWidget(index);
        if (key != null) {
          final List<Map<String, dynamic>> newSelected =
              List.from(selectedlist.value);
          newSelected.removeWhere((element) => element['duration'] == key);
          selectedlist.value = newSelected;
          widget.adPostCubit.deletePriceMapKey(key);
        }
      }, */
        );
  }

  Future<bool> getPrivacy(var userDoc) async {
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

  Widget nextButton() {
    final userDoc = chatFireStore
        .collection('privacy')
        .doc(authProvider.authUser!.userId.toString());
    return FutureBuilder(
        future: getPrivacy(userDoc),
        builder: (context, snapshot) {
          bool privacy = snapshot.hasData ? snapshot.data ?? true : true;
          return FilledButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.amber),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              onPressed: () async {
                // if (isPrivacyNotifierShown) {
                //   if (formValidate()) {
                //     loadingDialog(context);
                //     await widget.adPostCubit
                //         .createPost(
                //             widget.adPostCubit.adResponse != null
                //                 ? widget.adPostCubit.adResponse!.category
                //                 : widget.category!,
                //             widget.adPostCubit.adResponse != null
                //                 ? widget.adPostCubit.adResponse!.adType
                //                 : widget.adType!)
                //         .then((value) {
                //       Navigator.pop(context);
                //       if (value.success) {
                //         widget.adPostCubit.updateAdId(value.data!);
                //         Navigator.pushNamed(
                //             context, RouteConstants.adPostStage2,
                //             arguments: {
                //               'categoryTitle': widget.title ?? CategotyTitle,
                //               'adPostCubit': widget.adPostCubit
                //             });
                //       } else {
                //         Fluttertoast.showToast(
                //             msg: value.message ?? 'something went worng');
                //       }
                //     });
                //   } else {
                //     Fluttertoast.showToast(msg: 'Please check your form');
                //   }
                // } else {
                if (formValidate()) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(localisation(context).privacy),
                        content: Text(
                          privacy
                              ? localisation(context).contactPrivacyHidden
                              : localisation(context).contactPrivacyVisible,
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                style: const ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                    Constants.primaryColor,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    // isPrivacyNotifierShown = true;
                                    privacy = !privacy;
                                  });
                                  final docSnapshot = await userDoc.get();
                                  if (docSnapshot.exists) {
                                    await userDoc.update({
                                      'privacy': privacy,
                                      'name': authProvider.authUser!.name,
                                      'userid': authProvider.authUser!.userId
                                          .toString()
                                    });
                                  } else {
                                    await userDoc.set({
                                      'privacy': privacy,
                                      'name': authProvider.authUser!.name,
                                      'userid': authProvider.authUser!.userId
                                          .toString()
                                    });
                                  }
                                  loadingDialog(context);
                                  await widget.adPostCubit
                                      .createPost(
                                          widget.adPostCubit.adResponse != null
                                              ? widget.adPostCubit.adResponse!
                                                  .category
                                              : widget.category!,
                                          widget.adPostCubit.adResponse != null
                                              ? widget.adPostCubit.adResponse!
                                                  .adType
                                              : widget.adType!)
                                      .then((value) {
                                    Navigator.pop(context);
                                    if (value.success) {
                                      widget.adPostCubit
                                          .updateAdId(value.data!);
                                      Navigator.pushNamed(
                                          context, RouteConstants.adPostStage2,
                                          arguments: {
                                            'categoryTitle':
                                                widget.title ?? CategotyTitle,
                                            'adPostCubit': widget.adPostCubit
                                          });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: value.message ??
                                              'something went worng');
                                    }
                                  });
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                style: const ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll(
                                    Constants.primaryColor,
                                  ),
                                ),
                                child: const Text('No'),
                                onPressed: () async {
                                  loadingDialog(context);
                                  await widget.adPostCubit
                                      .createPost(
                                          widget.adPostCubit.adResponse != null
                                              ? widget.adPostCubit.adResponse!
                                                  .category
                                              : widget.category!,
                                          widget.adPostCubit.adResponse != null
                                              ? widget.adPostCubit.adResponse!
                                                  .adType
                                              : widget.adType!)
                                      .then((value) {
                                    Navigator.pop(context);
                                    if (value.success) {
                                      widget.adPostCubit
                                          .updateAdId(value.data!);
                                      Navigator.pushNamed(
                                          context, RouteConstants.adPostStage2,
                                          arguments: {
                                            'categoryTitle':
                                                widget.title ?? CategotyTitle,
                                            'adPostCubit': widget.adPostCubit
                                          });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: value.message ??
                                              'something went worng');
                                    }
                                  });

                                  // setState(() {
                                  //   isPrivacyNotifierShown = true;
                                  // });
                                  // Navigator.of(context).pop();
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                } else if (!priceDetailsError) {
                  Fluttertoast.showToast(msg: 'Please check your form ');
                }
              },
              child: const Text('Next'));
        });
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  final Duration duration;

  const BlinkingText({
    super.key,
    required this.text,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style:
            Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.red),
      ),
    );
  }
}
