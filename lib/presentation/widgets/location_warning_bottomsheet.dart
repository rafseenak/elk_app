// ignore_for_file: unused_import, unnecessary_import, deprecated_member_use

import 'package:elk/constants.dart';
import 'package:elk/constants/sizes.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/location_status_code.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/location_repository.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/exception/location_exception.dart';
import 'package:elk/presentation/pages/location_search_screen.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as location_service;

class LocationChooserWarning extends StatelessWidget {
  LocationChooserWarning({super.key});

  final ValueNotifier<bool> _lcationIsLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final LocationCubit locationCubit = BlocProvider.of<LocationCubit>(context);
    final PlaceRepository placeRepository =
        RepositoryProvider.of<PlaceRepository>(context);
    final LocationSearchCubit locationSearchCubit =
        LocationSearchCubit(placeRepository: placeRepository);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: canvasPadding, right: canvasPadding),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    localisation(context).whatsYourLocation,
                    style:
                        Theme.of(context).textTheme.headlineMedium!.copyWith(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    localisation(context).enjoyPersonalizedServiceAndRenting,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(height: 1.3),
                  ),
                ),
                Text(
                  localisation(context).experieceByTellingUsYourLocation,
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        "${StringConstants.imageAssetsPath}/earth_location.png",
                        width: 200,
                        height: 200,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.amber),
                      ),
                      onPressed: _lcationIsLoading.value
                          ? null
                          : () async {
                              try {
                                _lcationIsLoading.value = true;
                                final position = await determinePosition();
                                final place = await placeRepository.getPlace(
                                    position.longitude, position.latitude);
                                final location = Location.fromPlace(place!);
                                locationCubit
                                    .changeLocation(location)
                                    .then((value) {
                                  Navigator.pop(context);
                                  _lcationIsLoading.value = false;
                                });
                              } on LocationException catch (e) {
                                debugPrint(e.runtimeType.toString());
                                if (e.statusCode ==
                                    LocationStatusCode.locationDisabled) {
                                  if (await enableLocationService()) {
                                    final position = await determinePosition();
                                    final place =
                                        await placeRepository.getPlace(
                                            position.longitude,
                                            position.latitude);

                                    final location = Location.fromPlace(place!);
                                    locationCubit
                                        .changeLocation(location)
                                        .then((value) {
                                      Navigator.pop(context);
                                      _lcationIsLoading.value = false;
                                    });
                                  } else {
                                    _lcationIsLoading.value = false;
                                    Fluttertoast.showToast(
                                        msg: 'Please enable location service');
                                  }
                                } else if (e.statusCode ==
                                    LocationStatusCode
                                        .locationPermissionPermentlyDenied) {
                                  _lcationIsLoading.value = false;
                                  Geolocator.openAppSettings();
                                  Fluttertoast.showToast(
                                      msg: 'Please allow location permission');
                                } else {
                                  _lcationIsLoading.value = false;
                                  Fluttertoast.showToast(msg: e.message);
                                }
                              } catch (e) {
                                _lcationIsLoading.value = false;
                                debugPrint(e.toString());
                                Fluttertoast.showToast(
                                    msg: 'Something went erong');
                              }
                            },
                      child: ListenableBuilder(
                        listenable: _lcationIsLoading,
                        builder: (context, child) => !_lcationIsLoading.value
                            ? Text(
                                localisation(context).allowLocationAccess,
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      )),
                ),
                //
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: Center(
                      child: GestureDetector(
                        child: Text(
                          localisation(context).enterLocationManually,
                          style: const TextStyle(color: Constants.primaryColor),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                              isDismissible: false,
                              enableDrag: false,
                              useRootNavigator: true,
                              useSafeArea: false,
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return LocationSearch(false,
                                    locationSearchCubit: locationSearchCubit);
                              }).then((value) {
                            if (value is bool) {
                              if (true) {
                                Navigator.pop(context);
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
