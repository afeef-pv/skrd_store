import 'package:flutter/cupertino.dart';

class Item {
  int id;
  String shopId;
  String name;
  num count;
  num price;

  Item(
      {@required this.id,
      @required this.name,
      @required this.price,
      @required this.shopId,
      @required this.count});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        shopId: json['shopId'],
        count: json['count']);
  }
}
