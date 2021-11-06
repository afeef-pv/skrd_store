import 'package:flutter/cupertino.dart';
import 'package:silkraod_store/models/item.dart';

class Order {
  int id, status;
  String shopId, userId;
  DateTime createdAt;
  List<Item> items;
  double price;

  Order(
      {@required this.id,
      @required this.price,
      @required this.shopId,
      @required this.status,
      @required this.userId,
      @required this.items,
      @required this.createdAt});

  factory Order.fromJson(Map<String, dynamic> json) {
    List<Item> products = [];
    json['items'].forEach((element) {
      final Item product = Item.fromJson(element);
      products.add(product);
    });
    return Order(
        id: json['id'],
        price: json['price'] / 1.0,
        shopId: json['shopId'],
        status: json['status'],
        userId: json['userId'],
        items: products,
        createdAt: DateTime.parse(json['createdAt']));
  }
}
