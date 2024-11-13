// ignore_for_file: unused_import

import 'dart:async';

import 'package:elk/config/routes_constants.dart';
import 'package:elk/cubit/location_state.dart';
import 'package:elk/cubit/search_rent_item_cubit.dart';
import 'package:elk/cubit/search_rent_item_state.dart';
import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchRentItemScreen extends StatefulWidget {
  final String adType;

  const SearchRentItemScreen(this.adType, {super.key});
  @override
  State<SearchRentItemScreen> createState() => _SearchRentItemState();
}

class _SearchRentItemState extends State<SearchRentItemScreen> {
  late final searcRentItemBloc =
      SearchRentItemCubit(RepositoryProvider.of<RentAdsRepository>(context));
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();

  loadCategories(String keyword) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searcRentItemBloc.searchCategory(keyword, widget.adType);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 10),
            child: Container(),
          ),
          automaticallyImplyLeading: false,
          title: Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300)),
            child: Row(
              children: [
                const BackButton(),
                Expanded(
                  child: TextFormField(
                    focusNode: _focusNode,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.normal),
                    onChanged: loadCategories,
                    onFieldSubmitted: (value) {
                      Navigator.pushReplacementNamed(
                          context, RouteConstants.rentCategory,
                          arguments: {
                            'adType': widget.adType,
                            'keyword': value,
                          });
                    },
                    decoration: InputDecoration(
                        hintText: widget.adType == 'rent'
                            ? localisation(context).searchPropertiesCarsEtc
                            : localisation(context).searchElectricianPlumberEtc,
                        border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder(
            bloc: searcRentItemBloc,
            builder: (context, state) {
              if (state is SearchRentItemLoadState) {
                return ListView.separated(
                    separatorBuilder: (context, index) =>
                        index - 1 == state.currentData.length
                            ? Container()
                            : const Divider(
                                height: 0,
                              ),
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    itemCount: state.currentData.length,
                    itemBuilder: (context, index) => ListTile(
                          horizontalTitleGap: 10,
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          leading: const Icon(
                            Icons.search,
                          ),
                          title: Text(
                            state.currentData[index].keyword,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, RouteConstants.rentCategory,
                                arguments: {
                                  'adType': widget.adType,
                                  'category': state.currentData[index].category,
                                  'keyword': state.currentData[index].keyword,
                                });
                          },
                        ));
              } else {
                return Container();
              }
            }));
  }
}
