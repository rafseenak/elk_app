// ignore_for_file: unnecessary_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/entity/ad_user.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends StatelessWidget {
  final int? userId;
  const UserProfile(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo =
        RepositoryProvider.of<UserRepository>(context, listen: false);
    final future = userRepo.userWithAds(userId);
    return FutureBuilder<DataSet<AdUser>>(
        future: future,
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapShot.connectionState == ConnectionState.done &&
              snapShot.data!.success) {
            return Scaffold(
              appBar: AppBar(
                elevation: 1,
                shadowColor: Colors.grey,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    userProfile(context, snapShot.data!.data!),
                    ads(context, snapShot.data!.data!.ads)
                  ],
                ),
              ),
            );
          } else {
            return Text('Something went wrong: ${snapShot.data!.data}');
          }
        });
  }

  Widget userProfile(BuildContext context, AdUser adUser) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                adUser.name!,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
              ),
              ClipOval(
                child: adUser.profile != null && adUser.profile!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: adUser.profile!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Image.asset(
                          '${StringConstants.imageAssetsPath}/guest.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        '${StringConstants.imageAssetsPath}/guest.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),

              // ClipOval(
              //   child: CachedNetworkImage(
              //     imageUrl: adUser.profile!,
              //     width: 60,
              //     height: 60,
              //     fit: BoxFit.cover,
              //     errorWidget: (context, url, error) => Container(
              //       color: Colors.grey.shade200,
              //       child: Image.asset(
              //           width: 30,
              //           '${StringConstants.imageAssetsPath}/guest.png'),
              //     ),
              //   ),
              // )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(adUser.description ?? ''),
          ),
          Divider(
            color: Colors.grey.shade300,
            height: 30,
          )
        ],
      ),
    );
  }

  Widget ads(BuildContext context, List<Ad> list) {
    return GridView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        primary: false,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.7,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: list.length,
        itemBuilder: (context, index) => ad(context, list[index]));
  }

  Widget ad(BuildContext context, Ad ad) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 1,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: ad.adImages.first.image,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  maxWidthDiskCache: 500,
                  maxHeightDiskCache: 500,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.2)),
                  child: Text(
                    ad.category,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    ad.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Builder(builder: (context) {
                    final leastPrice = findLeastItem(
                        ad.adPriceDetails.map((e) => e.rentPrice).toList());
                    return Text(
                      '₹${leastPrice.value}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Constants.primaryColor),
                    );
                  }),
                )
              ],
            ),
          ),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(RouteConstants.rentItem, arguments: ad.adId);
              },
            ),
          ))
        ],
      ),
    );
  }
}
