import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';

class HomeRecomentedGridItem extends StatefulWidget {
  final AdResponse adResponse;

  const HomeRecomentedGridItem(this.adResponse, {Key? key}) : super(key: key);

  @override
  State<HomeRecomentedGridItem> createState() {
    return _HomeRecomentedGridItemBody();
  }
}

class _HomeRecomentedGridItemBody extends State<HomeRecomentedGridItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      color: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      surfaceTintColor: Theme.of(context).canvasColor,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          LayoutBuilder(builder: (context, contraints) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    filterQuality: FilterQuality.low,
                    imageUrl: widget.adResponse.adImages[0].image,
                    fadeInDuration: const Duration(milliseconds: 100),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey.shade100,
                    ),
                    height: 100,
                    width: double.infinity,
                    maxHeightDiskCache: 500,
                    maxWidthDiskCache: 500,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7, right: 5, top: 5),
                    child: Text(
                      widget.adResponse.title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
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
                              "${widget.adResponse.adLocation!.locality != null ? '${widget.adResponse.adLocation!.locality},' : ''} ${widget.adResponse.adLocation!.district}, ${widget.adResponse.adLocation!.state}, ${widget.adResponse.adLocation!.country}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(),
                              maxLines: 1,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: RichText(
                      text: TextSpan(
                          text: 'From ',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700),
                          children: [
                            TextSpan(
                                text:
                                    '₹${findLeastItem(widget.adResponse.adPriceDetails.map((e) => e.rentPrice).toList()).value}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Constants.primaryColor,
                                        fontWeight: FontWeight.w700))
                          ]),
                    ),
                  ),
                ]);
          }),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(RouteConstants.rentItem,
                    arguments: widget.adResponse.adId);

                /* context.push(RouteConstants.rentItem,
                    extra: widget.adResponse.adId); */
              },
            ),
          ))
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
