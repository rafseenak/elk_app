// ignore_for_file: unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:elk/config/routes_constants.dart';
import 'package:elk/constants/stringss.dart';
import 'package:elk/cubit/location_cubit.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/cubit/rent_products_cubit.dart';
import 'package:elk/cubit/rent_products_state.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/widgets/empty_list.dart';
import 'package:elk/presentation/widgets/products_list_item.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RentProductsScreen extends StatefulWidget {
  final String adType;
  final String? category;
  final String? keyword;

  final RentProductsCubit rentProductsCubit;
  const RentProductsScreen({
    super.key,
    required this.adType,
    this.category,
    this.keyword,
    required this.rentProductsCubit,
  });

  @override
  State<RentProductsScreen> createState() => _RentProductsState();
}

class _RentProductsState extends State<RentProductsScreen> {
  late final _locationCubit = BlocProvider.of<LocationCubit>(context);
  late final _rentProductsCubit = widget.rentProductsCubit;
  late final _location = (_locationCubit.state as LocationLoadState).location;
  final ScrollController scrollController = ScrollController();
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _rentProductsCubit.loadProducts(
        _location, widget.category, widget.keyword, widget.adType);
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      debugPrint('Scroll maximum');
      if (hasMore) {
        _rentProductsCubit.loadProducts(
            _location, widget.category, widget.keyword, widget.adType);
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentProductsCubit, RentProductsState>(
        bloc: _rentProductsCubit,
        builder: (context, state) {
          return Scaffold(
            body: Builder(builder: (context) {
              if (state is RentProductsInitialState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is RentProductsLoadState) {
                if (state.list.isEmpty) {
                  return EmptyList(localisation(context).noDataFound);
                }
                hasMore = state.hasMore;
                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverAppBar(bottom: sliverAppBarBottom(state)),
                    SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      if (state.hasMore && state.list.length == index) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ))),
                          ),
                        );
                      }
                      return ProductsListItem(state.list[index]);
                    },
                            childCount: state.hasMore
                                ? state.list.length + 1
                                : state.list.length))
                  ],
                );
              } else {
                return Container();
              }
            }),
          );
        });
  }

  PreferredSize? sliverAppBarBottom(RentProductsLoadState state) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 80),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
            text: TextSpan(
                text: state.total.toString(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: ' ${localisation(context).resultFound}')
                ]),
          ),
          searchBar(),
          const SizedBox(
            height: 10,
          )
        ]),
      ),
    );
  }

  Widget searchBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 60),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding:
                const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
            decoration: BoxDecoration(
                color: const Color(0XFFEAEAEA),
                borderRadius: BorderRadius.circular(10)),
            child: IntrinsicHeight(
              child: Row(children: [
                Expanded(
                    child: Text(
                  (widget.keyword != null && widget.category != null)
                      ? '${widget.keyword} in ${widget.category}'
                      : (widget.keyword != null && widget.category == null)
                          ? '${widget.keyword} in All categories'
                          : widget.category!,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                )),
                const VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                const Icon(
                  Icons.search,
                  color: Colors.grey,
                )
              ]),
            ),
          ),
          Positioned.fill(
              child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (widget.adType == 'rent') {
                      Navigator.pushNamed(
                          context, RouteConstants.searchRentItem,
                          arguments: {'adType': 'rent'});
                    } else {
                      Navigator.pushNamed(
                          context, RouteConstants.searchRentItem,
                          arguments: {'adType': 'service'});
                    }
                  }),
            ),
          ))
        ],
      ),
    );
  }
}
