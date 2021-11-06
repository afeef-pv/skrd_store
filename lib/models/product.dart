import 'package:flutter/cupertino.dart';

class Product {
  int id;
  String shopId;
  String name;
  String description;
  num quantity;
  num catId;
  num price;
  String imageUrl;
  bool isAvailable;

  Product(
      {@required this.id,
      @required this.name,
      @required this.description,
      @required this.quantity,
      @required this.catId,
      @required this.price,
      @required this.imageUrl,
      @required this.shopId,
      @required this.isAvailable});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        quantity: json['quantity'],
        catId: json['catId'],
        price: json['price'],
        imageUrl: json['imageUrl'],
        shopId: json['shopId'],
        isAvailable: json['isAvailable']);
  }
}
