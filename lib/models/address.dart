import 'package:flutter/cupertino.dart';

class Address {
  String phone, name, houseName, locality, location;
  int id, pin;

  Address(
      {@required this.id,
      @required this.phone,
      @required this.name,
      @required this.houseName,
      @required this.pin,
      @required this.locality,
      @required this.location});

  cords() {
    var cordstr = this.location.split(',');
    return [
      double.parse(cordstr[0]),
      double.parse(cordstr[1]),
    ];
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        id: json['id'],
        phone: json['phone'],
        name: json['name'],
        houseName: json['houseName'],
        pin: json['pin'],
        locality: json['locality'],
        location: json['location']);
  }
}
