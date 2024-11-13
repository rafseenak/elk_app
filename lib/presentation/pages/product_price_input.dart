// ignore_for_file: unnecessary_import, non_constant_identifier_names

import 'package:elk/constants.dart';
import 'package:elk/data/model/price_details.dart';
import 'package:elk/data/repository/common_repositor.dart';
import 'package:elk/data/resources/data_set.dart';
import 'package:elk/presentation/widgets/error_widget.dart';
import 'package:elk/utils/cutom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductPriceInputScreen extends StatefulWidget {
  const ProductPriceInputScreen({super.key});

  @override
  State<ProductPriceInputScreen> createState() {
    return _ProductPriceInputState();
  }
}

class _ProductPriceInputState extends State<ProductPriceInputScreen> {
  final CommonRepository _commonRepository = CommonRepository();

  Future<DataSet<Map>>? priceCategoryFuture;
  Map? priceCategories;
  List<String>? keys;
  List<String>? selectedItems;
  String? selectedCategory;
  String? SelectedpriceType;
  String? price;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    priceCategoryFuture = _commonRepository.priceCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Price details'),
        shadowColor: Colors.grey,
        elevation: 0.1,
        leading: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
          future: priceCategoryFuture,
          builder: (contetx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapShot.hasData &&
                snapShot.data!.success &&
                snapShot.data!.data!.isNotEmpty) {
              priceCategories = snapShot.data!.data;
              keys ??= List.generate(priceCategories!.keys.toList().length,
                  (index) => priceCategories!.keys.toList()[index]);

              if (selectedCategory != 'Custom' && selectedCategory == null) {
                selectedCategory ??= keys!.first.toString();
                selectedItems =
                    (priceCategories![selectedCategory!] as List<dynamic>)
                        .map((e) => e['title'] as String)
                        .toList();
              }

              if (!keys!.contains('Custom')) {
                keys!.add('Custom');
              }

              return ListView(
                padding: const EdgeInsets.only(left: 20, right: 20),
                children: [
                  text('Price category'),
                  const SizedBox(
                    height: 10,
                  ),
                  categoryItem(),
                  const SizedBox(
                    height: 20,
                  ),
                  text('Price type'),
                  const SizedBox(
                    height: 10,
                  ),
                  selectedCategory != 'Custom'
                      ? categoryItems('Choose')
                      : field('keyword', 'Enter your custom keyword',
                          TextInputType.text),
                  const SizedBox(
                    height: 10,
                  ),
                  text('Price'),
                  const SizedBox(
                    height: 10,
                  ),
                  field('price', 'Enter price', TextInputType.number),
                  const SizedBox(
                    height: 20,
                  ),
                  button(localisation(context).add)
                ],
              );
            } else {
              return const ErrorScreenWidget('Something went wrong');
            }
          }),
    );
  }

  Widget categoryItem() {
    return SingleChildScrollView(
      primary: false,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
            keys!.length,
            (index) => GestureDetector(
                  onTap: () {
                    _controller.clear();
                    if (keys![index] == 'Custom') {
                      setState(() {
                        selectedCategory = keys![index];
                        selectedItems = null;
                      });
                    } else {
                      setState(() {
                        selectedCategory = keys![index];
                        selectedItems = (priceCategories![selectedCategory!]
                                as List<dynamic>)
                            .map((e) => e['title'] as String)
                            .toList();
                      });
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      margin:
                          EdgeInsets.only(left: index == 0 ? 0 : 10, right: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: selectedCategory == keys![index] ? 2 : 1,
                        color: selectedCategory == keys![index]
                            ? Constants.primaryColor
                            : Colors.black,
                      )),
                      child: Text(keys![index])),
                )),
      ),
    );
  }

  Widget text(String title) {
    return Text(title);
  }

  Widget categoryItems(String label) {
    return selectedItems != null
        ? SizedBox(
            width: double.infinity,
            child: DropdownMenu(
              controller: _controller,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(),
              hintText: label,
              onSelected: (value) {
                setState(() {
                  SelectedpriceType = value;
                });
              },
              dropdownMenuEntries: selectedItems!
                  .map((e) => DropdownMenuEntry(value: e, label: e))
                  .toList(),
            ),
          )
        : const SizedBox();
  }

  Widget field(String type, String hint, TextInputType keyboardType) {
    return TextField(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
        decoration: InputDecoration(
          prefixIcon: type == 'price'
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      Constants.rupeeSymbol,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : null,
          hintText: hint,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        keyboardType: keyboardType,
        onChanged: (value) {
          if (type == 'price') {
            setState(() {
              if (value == '') {
                price = null;
              } else {
                price = value;
              }
            });
          } else {
            setState(() {
              if (value == '') {
                SelectedpriceType = null;
              } else {
                SelectedpriceType = value;
              }
            });
          }
        });
  }

  Widget button(String label) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.amber),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        onPressed: !(selectedCategory != null &&
                SelectedpriceType != null &&
                price != null)
            ? null
            : () {
                final data = PriceDetails(SelectedpriceType!, price!);
                Navigator.pop(context, data);
              },
        child: Text(label),
      ),
    );
  }
}
