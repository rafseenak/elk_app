// ignore_for_file: unused_import, unnecessary_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WishlistItem extends StatefulWidget {
  final int index;
  final AdResponse adResponse;
  final Function(int index) onRemove;
  const WishlistItem(this.index, this.adResponse,
      {required this.onRemove, super.key});

  @override
  State<WishlistItem> createState() {
    return _WishlistItemState();
  }
}

class _WishlistItemState extends State<WishlistItem> {
  late final UserRepository userRepository =
      RepositoryProvider.of<UserRepository>(context);
  bool wishListed = true;
  @override
  Widget build(BuildContext context) {
    return wishListed
        ? Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                //border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(RouteConstants.rentItem,
                    arguments: widget.adResponse.adId);
              },
              child: ListTile(
                  horizontalTitleGap: 5,
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                  leading: ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      child: CachedNetworkImage(
                          maxWidthDiskCache: 500,
                          maxHeightDiskCache: 500,
                          fit: BoxFit.cover,
                          width: 100,
                          imageUrl: widget.adResponse.adImages.first.image),
                    ),
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adResponse.title,
                        style:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.red.shade100),
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 2, bottom: 2),
                        child: Text(
                          widget.adResponse.category,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Builder(builder: (context) {
                        final least = findLeastItem(
                            (widget.adResponse.adPriceDetails)
                                .map((e) => e.rentPrice)
                                .toList());
                        return Text(
                          '₹${least.value}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 12),
                        );
                      })
                    ],
                  ),
                  trailing: GestureDetector(
                    onTap: () async {
                      setState(() {
                        wishListed = !wishListed;
                      });
                      await userRepository
                          .removeWishlist(widget.adResponse.adId, 2)
                          .then((value) {
                        if (value.success) {
                          widget.onRemove(widget.index);
                          Fluttertoast.showToast(msg: value.data!);
                        } else {
                          setState(() {
                            wishListed = !wishListed;
                          });
                        }
                      });
                    },
                    child: Icon(
                      wishListed ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.red,
                    ),
                  )),
            ),
          )
        : const SizedBox();
  }
}
