import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:silkraod_store/models/user.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silkraod_store/redux/actions.dart';

import '../globals.dart';

class FirebaseFCM extends StatefulWidget {
  final User user;
  FirebaseFCM({this.user});
  FirebaseFCMState createState() => FirebaseFCMState(user);
}

class FirebaseFCMState extends State<FirebaseFCM> {
  final User user;
  FirebaseFCMState(this.user);
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  _getToken() {
    _firebaseMessaging.getToken().then((token) {
      _configureFirebaseListener();
      _saveToken(token);
    });
  }

  void _storeShopData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('shop', json.encode(responseData));
  }

  _saveToken(token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${user.jwt}"
    };
    var body = {'userId': user.phone, 'token': token};
    http.Response response = await http.post(hostUrl + '/api/v0/fcmTokens',
        headers: headers, body: json.encode(body));
    if (response.statusCode == 201) {
      //redirect to the store
      _getShop();
    }
  }

  _getShop() async {
    http.Response response =
        await http.get(hostUrl + '/api/v0/shop/' + user.phone);
    if (response.statusCode == 200) {
      _storeShopData(json.decode(response.body));
      Navigator.pushReplacementNamed(context, '/store');
    } else {
      Navigator.pushReplacementNamed(context, '/storeAdd');
      // _showErrorSnack(json.decode(response.body)['message']);
    }
  }

  _configureFirebaseListener() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        StoreProvider.of(context).dispatch(getOrdersAction);
      },
      onLaunch: (Map<String, dynamic> message) async {
        StoreProvider.of(context).dispatch(getOrdersAction);
      },
      onResume: (Map<String, dynamic> message) async {
        StoreProvider.of(context).dispatch(getOrdersAction);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text('Firebase FCM'),
    ));
  }
}
