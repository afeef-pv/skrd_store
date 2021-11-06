import 'package:flutter/cupertino.dart';

class Shop {
  String phone, name, imageUrl, location;
  int catId;
  bool isOpen;
  Shop(
      {@required this.name,
      @required this.phone,
      @required this.imageUrl,
      @required this.location,
      @required this.catId,
      @required this.isOpen});

  factory Shop.fromJson(json) {
    return Shop(
        name: json['name'],
        phone: json['phone'],
        imageUrl: json['imageUrl'],
        location: json['location'],
        catId: json['catId'],
        isOpen: json['isOpen']);
  }
}
