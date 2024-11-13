// ignore_for_file: unused_import, empty_catches

import 'package:elk/bloc/event/myads_event.dart';
import 'package:elk/bloc/myads_bloc.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/ad_post_cubit.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/data/model/location.dart';
import 'package:elk/data/repository/place_repositoy.dart';
import 'package:elk/presentation/pages/location_chooser.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:elk/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdPostStage3Screen extends StatefulWidget {
  final String categoryTitle;
  final AdPostCubit adPostCubit;
  const AdPostStage3Screen(this.categoryTitle, this.adPostCubit, {super.key});

  @override
  State<AdPostStage3Screen> createState() {
    return _AdpostStaeg3State();
  }
}

class _AdpostStaeg3State extends State<AdPostStage3Screen> {
  late final locationCubt = BlocProvider.of<LocationCubit>(context);
  late final placeRepository =
      RepositoryProvider.of<PlaceRepository>(context, listen: false);
  Location? location;
  final isSubmiting = ValueNotifier(false);
  bool locatioIsLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        child: SizedBox(
          width: double.infinity,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text(
                'What is the location of the ${widget.categoryTitle} you are renting?',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: button('location',
                  '''${localisation(context).currentLocation} : ${locatioIsLoading ? 'loading...' : location != null ? (location!.locality != null && location!.locality != '') ? location!.locality : (location!.district != null && location!.district != '') ? location!.district : (location!.state != null && location!.state != '') ? location!.state : (location!.country != '') ? location!.country : '' : ''} ''',
                  () async {
                try {
                  setState(() {
                    locatioIsLoading = true;
                  });
                  final position = await determinePosition();
                  //final position = await Geolocator.getCurrentPosition();
                  final place = await placeRepository.getPlace(
                      position.longitude, position.latitude);

                  final locationPlcae = Location.fromPlace(place!);

                  setState(() {
                    location = locationPlcae;
                  });
                } catch (e) {}
                setState(() {
                  locatioIsLoading = false;
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: button('other', localisation(context).someWhereElse,
                  () async {
                final contextLocation = await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => const LocationChooser(true));
                if (contextLocation != null) {
                  setState(() {
                    location = contextLocation;
                  });
                }
              }),
            ),
            const Spacer(),
            nextButton()
          ]),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(localisation(context).location),
          Text(
            localisation(context).addYourLocationDetails,
            style: Theme.of(context)
                .appBarTheme
                .titleTextStyle!
                .copyWith(fontSize: 12),
          ),
        ],
      ),
      elevation: 1,
    );
  }

  Widget button(String type, String title, Function() onTap) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          onPressed: onTap,
          child: type != 'location'
              ? Text(title)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      size: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(title),
                    )
                  ],
                )),
    );
  }

  Widget nextButton() {
    return SizedBox(
        height: 40,
        width: double.infinity,
        child: ValueListenableBuilder<bool>(
            valueListenable: isSubmiting,
            builder: (context, loading, child) => FilledButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.amber),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                onPressed: loading || location == null
                    ? null
                    : () async {
                        if (!locatioIsLoading) {
                          if (location != null) {
                            isSubmiting.value = true;
                            await widget.adPostCubit.rentAdsRepository
                                .adPostAddress(
                                    widget.adPostCubit.adId!, location!,
                                    adStage:
                                        widget.adPostCubit.adResponse?.adStage,
                                    adStatus:
                                        widget.adPostCubit.adResponse?.adStatus)
                                .then((value) {
                              if (value.success) {
                                Navigator.pushNamed(
                                    context, RouteConstants.postSuccess,
                                    arguments: {
                                      'adId': widget.adPostCubit.adId
                                    });
                                context.read<MyAdsBloc>().add(MyAdsLoadEvent());
                              } else {
                                Fluttertoast.showToast(
                                    msg: value.message.toString());
                              }
                            });
                            isSubmiting.value = false;
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please choose location');
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please wait fetching location....');
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )),
                      )
                    : Text(localisation(context).submit))));
  }
}
