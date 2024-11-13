// ignore_for_file: unused_import

import 'package:elk/data/model/user_model.dart';
import 'package:elk/provider/profile_provider.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final ProfileProvider profileProvider;
  const ProfileUpdateScreen({super.key, required this.profileProvider});

  @override
  State<ProfileUpdateScreen> createState() {
    return _ProfileUpdateState();
  }
}

class _ProfileUpdateState extends State<ProfileUpdateScreen> {
  final ValueNotifier<bool> _valueNotifier = ValueNotifier(false);
  late String? name = widget.profileProvider.user!.name!;
  late String? description = widget.profileProvider.user!.decription;
  final _formKey = GlobalKey<FormState>();

  changeName(String name) {
    this.name = name;
  }

  changeDecription(String description) {
    this.description = description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ChangeNotifierProvider<ProfileProvider>.value(
        value: widget.profileProvider,
        child: Consumer<ProfileProvider>(builder: (context, state, child) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  textField(localisation(context).name, state.user!.name,
                      changeName, validateName),
                  textField(
                      localisation(context).description,
                      state.user!.decription,
                      changeDecription,
                      validateDescription),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: loadingButton(
                        _valueNotifier, localisation(context).submit, () {
                      if (_formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        _valueNotifier.value = true;
                        state.updateProfile(name!, description!).then((value) {
                          if (value.success) {
                            Fluttertoast.showToast(msg: value.data!);
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(msg: value.message!);
                          }
                          _valueNotifier.value = false;
                        });
                      }
                    }),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(localisation(context).updateProfile),
      centerTitle: true,
      elevation: 0.5,
    );
  }

  Widget textField(
      String label, String? value, Function(String)? onChange, validator) {
    return TextFormField(
      initialValue: value,
      keyboardType: label == localisation(context).name
          ? TextInputType.name
          : TextInputType.multiline,
      minLines: label == localisation(context).name ? 1 : 5,
      maxLines: 5,
      onChanged: onChange,
      validator: validator,
      decoration: InputDecoration(hintText: label),
    );
  }

  Widget loadingButton(
      ValueNotifier<bool> notifier, String text, Function() onTap) {
    return ValueListenableBuilder<bool>(
        valueListenable: notifier,
        builder: (context, loading, child) => SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                  onPressed: loading ? null : onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                  child: !loading
                      ? Text(text)
                      : const SizedBox(
                          width: 15,
                          height: 15,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.white,
                          )),
                        )),
            ));
  }
}
