// ignore_for_file: deprecated_member_use, unused_import, unnecessary_import, empty_catches, no_leading_underscores_for_local_identifiers

import 'package:elk/cubit/loaction_search_state.dart';
import 'package:elk/cubit/location_search_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/enum/location_type.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/network/entity/place_entity.dart';
import 'package:elk/network/entity/place_search.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../data/resources/data_set.dart';

class LocationChooser extends StatefulWidget {
  final bool limitedSearch;
  const LocationChooser(this.limitedSearch, {super.key});

  @override
  State<LocationChooser> createState() {
    return _LocationChooser();
  }
}

class _LocationChooser extends State<LocationChooser> {
  late final PlaceRepository placeRepository =
      RepositoryProvider.of<PlaceRepository>(context, listen: false);
  late final LocationSearchCubit _locationSearchCubit =
      LocationSearchCubit(placeRepository: placeRepository);

  String? title;
  final TextEditingController _textEditingController = TextEditingController();
  List<Widget> pageViewChildresn = [];
  final PageController _pageController = PageController();
  int currentPage = 1;
  final currentLocationIsSelecting = ValueNotifier(false);

  Future<DataSet<List<PlaceSimple>>>? stateFuture;
  Future<DataSet<List<PlaceSimple>>>? cityFuture;
  Future<DataSet<List<PlaceSimple>>>? localityFuture;

  String? locality;
  String? place;
  String? district;
  String? state;
  String country = 'India';

  @override
  void initState() {
    super.initState();
    stateFuture = placeRepository.getPlaces('state');
    pageViewChildresn.add(stateWidget('state', stateFuture!));
  }

  @override
  void dispose() {
    _locationSearchCubit.close();
    _pageController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage == 1) {
          return true;
        } else {
          currentPage--;
          pageViewChildresn.removeLast();
          _pageController.previousPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear);
          setState(() {});

          return false;
        }
      },
      child: BlocBuilder<LocationSearchCubit, LocationSearchState>(
          bloc: _locationSearchCubit,
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF4F6FB),
              appBar: appBar(context, state),
              body: Column(
                children: [
                  searchBar(context, state),
                  if (state is InitialLocationSearchState)
                    /* Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _pageController,
                          children: pageViewChildresn,
                        ),
                      ),
                    ) */
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: currentLoactionButton(context),
                    )
                  else
                    placesList(
                        context, (state as LoadPlacesDataState).currentData)
                ],
              ),
            );
          }),
    );
  }

  AppBar appBar(BuildContext context, LocationSearchState locationSearchState) {
    return AppBar(
      toolbarHeight: 40,
      automaticallyImplyLeading: false,
      systemOverlayStyle: Theme.of(context)
          .appBarTheme
          .systemOverlayStyle!
          .copyWith(statusBarColor: const Color(0xFFF4F6FB)),
      backgroundColor: const Color(0xFFF4F6FB),
      bottom: PreferredSize(
        preferredSize: Size(double.infinity, AppBar().preferredSize.height),
        child: AppBar(
          systemOverlayStyle: Theme.of(context)
              .appBarTheme
              .systemOverlayStyle!
              .copyWith(statusBarColor: const Color(0xFFF4F6FB)),
          backgroundColor: const Color(0xFFF4F6FB),
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.location,
            style: Theme.of(context).appBarTheme.titleTextStyle!.copyWith(),
          ),
        ),
      ),
    );
  }

  Widget searchBar(
      BuildContext context, LocationSearchState locationSearchState) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
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
            if (value.length < 3) {
            } else {
              int searchLimit = 0;
              if (locationSearchState is LoadPlacesDataState) {
                searchLimit = locationSearchState.currentData.length;
              }
              _locationSearchCubit.searchLocations(
                  value, widget.limitedSearch, searchLimit);
            }
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

  Widget currentLoactionButton(
    BuildContext context,
  ) {
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
                              currentLocationIsSelecting.value = false;
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                Navigator.pop(context, location);
                              });
                            } catch (e) {}
                            //await Geolocator.getCurrentPosition();
                          }),
              ))
            ],
          );
        });
  }

  Widget stateWidget(String type, Future<DataSet<List<PlaceSimple>>> future) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (type == 'state')
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: currentLoactionButton(context),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 25, right: 20),
          child: Text('Choose $type'),
        ),
        FutureBuilder(
            future: future,
            builder: (context, snapSot) {
              if (snapSot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapSot.connectionState == ConnectionState.done &&
                  snapSot.hasData) {
                if (snapSot.data!.success) {
                  return Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children:
                          List.generate(snapSot.data!.data!.length, (index) {
                        final simplePlace = snapSot.data!.data![index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                              onTap: () {
                                if (type == 'state') {
                                  state = simplePlace.value;
                                  if (simplePlace.count > 0) {
                                    currentPage++;

                                    cityFuture = placeRepository.getPlaces(
                                      'city',
                                      state: state,
                                    );

                                    final List<Widget> list =
                                        List.from(pageViewChildresn);
                                    list.add(stateWidget('city', cityFuture!));
                                    pageViewChildresn = list;
                                    setState(() {});
                                    _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: (Curves.linear));
                                  } else {
                                    final location = Location(
                                        locationType: LocationType.state,
                                        country: country,
                                        state: state,
                                        district: null,
                                        locality: null,
                                        latitude: simplePlace.latitude,
                                        longitude: simplePlace.longitude);
                                    Navigator.pop(context, location);
                                  }
                                } else if (type == 'district') {
                                  district = simplePlace.value;
                                  if (simplePlace.count > 0) {
                                    currentPage++;

                                    localityFuture = placeRepository.getPlaces(
                                        'locality',
                                        state: state,
                                        district: district);

                                    final List<Widget> list =
                                        List.from(pageViewChildresn);
                                    list.add(stateWidget(
                                        'locality', localityFuture!));
                                    pageViewChildresn = list;
                                    setState(() {});
                                    _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: (Curves.linear));
                                  } else {
                                    final location = Location(
                                        locationType: LocationType.district,
                                        country: country,
                                        state: state,
                                        district: district,
                                        locality: locality,
                                        latitude: simplePlace.latitude,
                                        longitude: simplePlace.longitude);
                                    Navigator.pop(context, location);
                                  }
                                } else {
                                  district = simplePlace.value;
                                  final location = Location(
                                      locationType: LocationType.district,
                                      country: country,
                                      state: state,
                                      district: district,
                                      locality: locality,
                                      latitude: simplePlace.latitude,
                                      longitude: simplePlace.longitude);
                                  Navigator.pop(context, location);
                                }
                              },
                              child: Ink(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10, bottom: 10),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          simplePlace.value,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(fontSize: 15),
                                        ),
                                        if (simplePlace.count > 0)
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 15,
                                          )
                                      ]))),
                        );
                      }),
                    ),
                  );
                } else {
                  return Text(snapSot.data!.message.toString());
                }
              } else {
                return const Text('Something went wrong');
              }
            })
      ]),
    );
  }

  Widget placesList(BuildContext context, List<PlaceSearch> location) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(10)),
        child: SingleChildScrollView(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined),
                                      if (location[index].distance != null)
                                        Text(
                                            location[index].distance.toString())
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                            child: InkWell(onTap: () {
                              FocusScope.of(context).unfocus();

                              final _loaction =
                                  Location.fromPlaceSearch(location[index]);

                              Navigator.pop(context, _loaction);
                            }),
                          ),
                        ))
                      ],
                    )),
          ),
        ),
      ),
    );
  }
}
