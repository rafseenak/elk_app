// import 'package:elk/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:elk/utils/cutom_utils.dart';

// ignore: must_be_immutable

class PriceDetailWidget extends StatefulWidget {
  final String priceType;
  final String price;
  final VoidCallback delete;

  const PriceDetailWidget(this.priceType, this.price, this.delete, {Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _PriceDetailWidget();
  }
}

class _PriceDetailWidget extends State<PriceDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localisation(context).service),
                SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                        style:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(),
                        initialValue: "Per ${widget.priceType}",
                        decoration: const InputDecoration(
                            border: UnderlineInputBorder()),
                        enabled: false),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localisation(context).price),
                SizedBox(
                  width: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                        style:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(),
                        initialValue: widget.price,
                        decoration: const InputDecoration(
                            prefixText: '₹', border: UnderlineInputBorder()),
                        enabled: false),
                  ),
                ),
              ],
            )
          ]),
          const Divider(),
          IconButton(
              onPressed: () {
                widget.delete();
              },
              icon: const Icon(Icons.delete_forever))
        ],
      ),
    );
  }
}
