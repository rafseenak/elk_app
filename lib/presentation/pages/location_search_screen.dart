// ignore_for_file: unused_import, unnecessary_import, deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'package:elk/constants/sizes.dart';
import 'package:elk/cubit/loaction_search_state.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/location_status_code.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/exception/location_exception.dart';
import 'package:elk/network/entity/place_search.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class LocationSearch extends StatefulWidget {
  final bool limitedSearch;
  final LocationSearchCubit locationSearchCubit;
  const LocationSearch(this.limitedSearch,
      {super.key, required this.locationSearchCubit});

  @override
  State<LocationSearch> createState() => _LocationSearch();
}

class _LocationSearch extends State<LocationSearch> {
  late final LocationSearchCubit _locationSearchCubit =
      widget.locationSearchCubit;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  late final LocationCubit locationCubit =
      BlocProvider.of<LocationCubit>(context);
  late final PlaceRepository placeRepository =
      RepositoryProvider.of<PlaceRepository>(context);
  final currentLocationIsSelecting = ValueNotifier(false);
  final manualLocationIsSelecting = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    //_scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    //_scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentLocationIsSelecting.value ||
            manualLocationIsSelecting.value) {
          return false;
        }
        return true;
      },
      child: BlocBuilder<LocationSearchCubit, LocationSearchState>(
        bloc: _locationSearchCubit,
        builder: (context, state) => SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F6FB),
            appBar: AppBar(
                automaticallyImplyLeading: false,
                systemOverlayStyle: Theme.of(context)
                    .appBarTheme
                    .systemOverlayStyle!
                    .copyWith(statusBarColor: const Color(0xFFF4F6FB)),
                backgroundColor: const Color(0xFFF4F6FB),
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize:
                      Size(double.infinity, AppBar().preferredSize.height + 60),
                  child: Column(
                    children: [
                      AppBar(
                        backgroundColor: const Color(0xFFF4F6FB),
                        title: Text(
                          AppLocalizations.of(context)!.location,
                          style: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle!
                              .copyWith(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10),
                        child: searchBar(context, state),
                      ),
                    ],
                  ),
                )),
            body: NotificationListener<ScrollEndNotification>(
              onNotification: (scrollEndNotification) {
                if (scrollEndNotification.metrics.pixels ==
                    scrollEndNotification.metrics.maxScrollExtent) {
                  if (state is LoadPlacesDataState) {
                    if (state.addMoreAvailable) {
                      _locationSearchCubit.searchLocations(
                          _textEditingController.value.text,
                          widget.limitedSearch,
                          state.currentData.length);
                    }
                  }
                }

                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(children: [
                  currentLoactionButton(context),
                  if (state is LoadPlacesDataState)
                    ValueListenableBuilder(
                      valueListenable: manualLocationIsSelecting,
                      builder: (context, isManualSelecting, child) =>
                          !isManualSelecting
                              ? placesList(
                                  context, isManualSelecting, state.currentData)
                              : const Padding(
                                  padding: EdgeInsets.only(top: 100),
                                  child: Center(
                                      child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    ),
                                  )),
                                ),
                    )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBar(
      BuildContext context, LocationSearchState locationSearchState) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10)),
        child: TextField(
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.normal),
          textCapitalization: TextCapitalization.words,
          controller: _textEditingController,
          onChanged: (value) {
            _locationSearchCubit.searchLocations(
                value,
                widget.limitedSearch,
                locationSearchState is InitialLocationSearchState
                    ? 0
                    : (locationSearchState as LoadPlacesDataState)
                        .currentData
                        .length);
          },
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(15),
              hintText: localisation(context).eneterYourCity,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search)),
        ),
      ),
    );
  }

  Widget currentLoactionButton(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: currentLocationIsSelecting,
        builder: (context, isSelecting, child) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.only(
                    left: 15, right: 10, top: 10, bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                          AppLocalizations.of(context)!.useCurrentLocation),
                    ),
                    const Spacer(),
                    if (!isSelecting)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      )
                    else
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: isSelecting
                        ? null
                        : () async {
                            try {
                              currentLocationIsSelecting.value = true;
                              final position = await determinePosition();
                              //final position = await Geolocator.getCurrentPosition();
                              final place = await placeRepository.getPlace(
                                  position.longitude, position.latitude);

                              final location = Location.fromPlace(place!);
                              locationCubit
                                  .changeLocation(location)
                                  .then((value) {
                                currentLocationIsSelecting.value = false;
                                Navigator.pop(context, true);
                              });
                            } on LocationException catch (e) {
                              debugPrint(e.runtimeType.toString());
                              if (e.statusCode ==
                                  LocationStatusCode.locationDisabled) {
                                if (await enableLocationService()) {
                                  final position = await determinePosition();
                                  final place = await placeRepository.getPlace(
                                      position.longitude, position.latitude);

                                  final location = Location.fromPlace(place!);
                                  locationCubit
                                      .changeLocation(location)
                                      .then((value) {
                                    Navigator.pop(context);
                                    currentLocationIsSelecting.value = false;
                                  });
                                } else {
                                  currentLocationIsSelecting.value = false;
                                  Fluttertoast.showToast(
                                      msg: 'Please enable location service');
                                }
                              } else if (e.statusCode ==
                                  LocationStatusCode
                                      .locationPermissionPermentlyDenied) {
                                currentLocationIsSelecting.value = false;
                                Geolocator.openAppSettings();
                                Fluttertoast.showToast(
                                    msg: 'Please allow location permission');
                              } else {
                                currentLocationIsSelecting.value = false;
                                Fluttertoast.showToast(msg: e.message);
                              }
                            } catch (e) {
                              currentLocationIsSelecting.value = false;

                              Fluttertoast.showToast(
                                  msg: 'Something went wrong');
                            }
                            //await Geolocator.getCurrentPosition();
                          }),
              ))
            ],
          );
        });
  }

  Widget placesList(
      BuildContext context, bool isSelecting, List<PlaceSearch> location) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: List.generate(
            location.length,
            (index) => Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined),
                                  if (location[index].distance != null)
                                    Text(location[index].distance.toString())
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(location[index].locality ??
                                        location[index].district ??
                                        location[index].state ??
                                        location[index].country),
                                    if (location[index].state != null)
                                      Text(location[index].state!)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        if (location.length != (index + 1))
                          const Divider(
                            height: 0,
                          )
                      ],
                    ),
                    Positioned.fill(
                        child: ClipRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            onTap: isSelecting
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
                                    manualLocationIsSelecting.value = true;
                                    final __loaction = Location.fromPlaceSearch(
                                        location[index]);
                                    locationCubit
                                        .changeLocation(__loaction)
                                        .then((value) {
                                      manualLocationIsSelecting.value = false;
                                      Navigator.pop(context, true);
                                    });
                                  }),
                      ),
                    ))
                  ],
                )),
      ),
    );
  }
}
