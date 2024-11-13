// ignore_for_file: unnecessary_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/data/enum/user_type.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductsListItem extends StatefulWidget {
  final AdResponse adResponse;
  const ProductsListItem(this.adResponse, {super.key});

  @override
  State<ProductsListItem> createState() {
    return _ProductsListItemBody();
  }
}

class _ProductsListItemBody extends State<ProductsListItem> {
  late final rentAdsRepository =
      RepositoryProvider.of<RentAdsRepository>(context);
  final wishListNotifer = ValueNotifier<bool>(false);
  bool? whishListed;

  @override
  void initState() {
    whishListed = widget.adResponse.wishListed ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      child: Card(
        elevation: 0.2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              filterQuality: FilterQuality.low,
              imageUrl: widget.adResponse.adImages[0].image,
              width: 100,
              height: 80,
              maxHeightDiskCache: 500,
              maxWidthDiskCache: 500,
              fit: BoxFit.cover,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.adResponse.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Builder(builder: (context) {
                  return ValueListenableBuilder<bool>(
                      valueListenable: wishListNotifer,
                      builder: (context, loading, child) {
                        return GestureDetector(
                          onTap: () async {
                            if (getUserType(context) == UserType.user) {
                              if (!loading) {
                                wishListNotifer.value = !wishListNotifer.value;
                                await rentAdsRepository
                                    .addToWishlist(widget.adResponse.adId)
                                    .then((value) {
                                  if (value.success) {
                                    whishListed = !whishListed!;
                                    setState(() {});

                                    Fluttertoast.showToast(
                                        msg: value.data!.toString());
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: 'Something went wrong');
                                  }
                                });
                                wishListNotifer.value = !wishListNotifer.value;
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Please wait before new request');
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Guest user does't have this permission");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: !whishListed!
                                ? const Icon(
                                    Icons.bookmark_outline,
                                    color: Colors.grey,
                                  )
                                : const Icon(
                                    Icons.bookmark,
                                    color: Constants.primaryColor,
                                  ),
                          ),
                        );
                      });
                })
              ],
            ),
          ),
          onTap: () async {
            await Navigator.of(context)
                .pushNamed(RouteConstants.rentItem,
                    arguments: widget.adResponse.adId)
                .then((value) {
              if (value is bool) {
                if (value == true) {
                  setState(() {
                    whishListed = !whishListed!;
                  });
                }
              }
            });
          },
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: Constants.primaryColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        '${widget.adResponse.adLocation!.locality != null ? '${widget.adResponse.adLocation!.locality},' : ''} ${widget.adResponse.adLocation!.district},${widget.adResponse.adLocation!.state}, ${widget.adResponse.adLocation!.country}',
                        style:
                            Theme.of(context).textTheme.bodySmall!.copyWith(),
                        maxLines: 1,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Text(
              "₹${widget.adResponse.adPriceDetails[0].rentPrice}",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Constants.primaryColor,
                  height: 1.5),
            ),
          ]),
        ),
      ),
    );
  }
}
