import 'package:flutter/cupertino.dart';

class User {
  String name;
  String phone;
  String jwt;

  User({@required this.name, @required this.phone, @required this.jwt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(name: json['name'], phone: json['phone'], jwt: json['jwt']);
  }
}
