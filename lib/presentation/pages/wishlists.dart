// ignore_for_file: unused_import

import 'package:elk/data/repository/rent_ads_repository.dart';
import 'package:elk/data/repository/user_repository.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/network/entity/ad_response.dart';
import 'package:elk/presentation/widgets/empty_list.dart';
import 'package:elk/presentation/widgets/error_widget.dart';
import 'package:elk/presentation/widgets/loading_widget.dart';
import 'package:elk/presentation/widgets/whishlist_item.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishListsScreen extends StatefulWidget {
  const WishListsScreen({super.key});

  @override
  State<WishListsScreen> createState() {
    return _WishListsScreenBody();
  }
}

class _WishListsScreenBody extends State<WishListsScreen> {
  late final UserRepository userRepo =
      RepositoryProvider.of<UserRepository>(context);

  Future<DataSet<List<AdResponse>>>? wishlistsFuture;

  @override
  void initState() {
    super.initState();
    wishlistsFuture = userRepo.userWishlists();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSet<List<AdResponse>>>(
      future: wishlistsFuture,
      builder: (contetx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const LoadinWidget();
        } else if (snapShot.hasData && snapShot.data != null) {
          final list = snapShot.data!.data!;
          if (list.isEmpty) {
            return EmptyList(localisation(context).noWishlist);
          } else {
            return Scaffold(
              appBar: AppBar(
                shadowColor: Colors.grey.shade300,
                title: Text(
                  localisation(context).myWishList,
                  style:
                      Theme.of(context).appBarTheme.titleTextStyle!.copyWith(),
                ),
                centerTitle: true,
                elevation: 1,
              ),
              body: ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  itemCount: list.length,
                  itemBuilder: (context, index) => WishlistItem(
                        index,
                        list[index],
                        onRemove: (index) {},
                      )),
            );
          }
        } else {
          return const ErrorScreenWidget('Something went wrong');
        }
      },
    );
  }
}
