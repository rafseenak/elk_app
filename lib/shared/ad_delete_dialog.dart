import 'package:elk/bloc/event/myads_event.dart';
import 'package:elk/bloc/myads_bloc.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdDeleteDialog extends StatelessWidget {
  final dynamic adId;
  final String title;

  const AdDeleteDialog({super.key, required this.adId, required this.title});

  @override
  Widget build(BuildContext context) {
    final RentAdsRepository rentAdsRepository =
        RepositoryProvider.of<RentAdsRepository>(context);
    final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

    return AlertDialog(
        titleTextStyle: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        title: Text(localisation(context).deleteAd),
        content: Text(
            '${localisation(context).doYouWantTpDeleteTjisAd} ' "'$title'"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localisation(context).cancel)),
          TextButton(
              onPressed: () {
                loadingNotifier.value = true;
                rentAdsRepository.deleteAd(adId).then((value) {
                  if (value.success) {
                    Navigator.pop(context);
                    context.read<MyAdsBloc>().add(MyAdsLoadEvent());
                  } else {
                    Navigator.pop(context);
                  }
                  loadingNotifier.value = false;
                });
              },
              child: ValueListenableBuilder(
                valueListenable: loadingNotifier,
                builder: (context, loading, child) {
                  if (loading) {
                    return const SizedBox(
                      width: 15,
                      height: 15,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Text(localisation(context).delete);
                  }
                },
              ))
        ]);
  }
}
