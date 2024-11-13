// ignore_for_file: deprecated_member_use

import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';

class UnsavedPostDialog extends StatelessWidget {
  final AdResponse adResponse;
  final AdPostCubit adPostCubit;
  const UnsavedPostDialog(
      {super.key, required this.adResponse, required this.adPostCubit});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Wrap(
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10), right: Radius.circular(20))),
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(50)),
                  child: const SizedBox(
                    width: 150,
                    height: 10,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    localisation(context).continueWhereYouLeftOf,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  localisation(context).pickupFromWhereYouLeftTheFormLastTime,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(150, 40),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            Navigator.pop(context);
                            adPostCubit.iniiState();
                          },
                          child: Text(localisation(context).cancel)),
                      TextButton(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(150, 40),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            adPostCubit.loadRecentAd(adResponse);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, RouteConstants.adPostStage1,
                                arguments: {'adPostCubit': adPostCubit});
                          },
                          child: Text(localisation(context).conTinue))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
