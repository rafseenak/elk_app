// ignore_for_file: unused_import, unnecessary_import, avoid_unnecessary_containers

import 'package:elk/bloc/event/language_screen_event.dart';
import 'package:elk/bloc/language_selection_bloc.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/lists.dart';
import 'package:elk/constants/sizes.dart';
import 'package:elk/main.dart';
import 'package:elk/presentation/pages/login_screen.dart';
import 'package:elk/config/routes.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final LanguageSelectionBloc languageSelectionBloc;
  final bool isInitialPage;
  const LanguageSelectionScreen(
      {super.key,
      required this.isInitialPage,
      required this.languageSelectionBloc});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelectionScreen> {
  LanguageSelectionBloc? _languageSelectionBloc;

  @override
  void initState() {
    super.initState();
    _languageSelectionBloc = widget.languageSelectionBloc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: widget.isInitialPage ? 0 : null,
        title: widget.isInitialPage
            ? null
            : Text(
                AppLocalizations.of(context)!.changeLanguage,
                style: Theme.of(context)
                    .appBarTheme
                    .titleTextStyle!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: canvasPadding, right: canvasPadding),
        child: Column(
          children: [
            if (widget.isInitialPage)
              Container(
                padding: const EdgeInsets.only(bottom: lastItemMargin),
                child: Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                  textScaler: TextScaler.linear(textScaleFactor(context)),
                ),
              ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => Stack(
                  children: [
                    BlocBuilder<LanguageSelectionBloc, String>(
                        bloc: _languageSelectionBloc,
                        builder: (context, state) {
                          return Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                    color: Color(0XFFF5F5F5)),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      ListConstants.languages[index]['image']!,
                                      width: 100,
                                      isAntiAlias: true,
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                          ListConstants.languages[index]
                                              ['title']!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontWeight: (ListConstants
                                                                  .languages[
                                                              index]['title'] ==
                                                          'English')
                                                      ? FontWeight.w900
                                                      : FontWeight.w800),
                                        )),
                                    const Spacer(),
                                    Radio(
                                        value: ListConstants.languages[index]
                                            ['title']!,
                                        groupValue: state,
                                        onChanged: (d) {})
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                    Positioned.fill(
                        child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          _languageSelectionBloc!.add(LanguageSelectionEvent(
                              ListConstants.languages[index]['title']!));
                          appLanguageNotifier.changeCurrentLanguage(Locale(
                              ListConstants.languages[index]
                                  ['language_code']!));
                        },
                      ),
                    ))
                  ],
                ),
                separatorBuilder: (context, index) =>
                    const Padding(padding: EdgeInsets.only(bottom: 20)),
                itemCount: ListConstants.languages.length,
              ),
            ),
            BlocBuilder<LanguageSelectionBloc, String>(
                bloc: _languageSelectionBloc,
                builder: (context, state) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.amber),
                      ),
                      onPressed: state == ''
                          ? null
                          : () {
                              if (widget.isInitialPage) {
                                Navigator.pushNamed(
                                  context,
                                  RouteConstants.login,
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            },
                      child: Text(
                        AppLocalizations.of(context)!.conTinue,
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
