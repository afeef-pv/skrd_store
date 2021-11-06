import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/pages/order_detail_page.dart';
import 'package:silkraod_store/redux/actions.dart';
import 'package:http/http.dart' as http;
import '../globals.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CartPage extends StatefulWidget {
  final void Function() onInit;
  CartPage({this.onInit});
  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  bool _isOpen = true;
  FirebaseMessaging _firebaseMessaging;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    super.initState();
    widget.onInit();
    _firebaseMessaging = FirebaseMessaging();
    _configureFirebaseListener();
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

  Widget _ordersTab(state) {
    return ListView(
        children: state.orders.length > 0
            ? state.orders
                .map<Widget>((order) => (ListTile(
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return OrderDetailPage(order: order);
                      })),
                      title: order.status == 0
                          ? Text('Rs ${order.price}/- placed',
                              style: TextStyle(fontSize: 18))
                          : order.status == 1
                              ? Text('Rs ${order.price}/- accepted',
                                  style: TextStyle(fontSize: 18))
                              : Text('Rs ${order.price}/- completed',
                                  style: TextStyle(fontSize: 18)),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy - hh:mm')
                            .format(order.createdAt),
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: order.status == 0
                            ? Colors.orange
                            : order.status == 1 ? Colors.green : Colors.red,
                        child: Icon(
                          Icons.attach_money,
                          color: Colors.white,
                        ),
                      ),
                      trailing: order.status == 0
                          ? FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Text('Reject',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink)),
                              onPressed: () => _deletOrder(state, order.id),
                            )
                          : Text(''),
                    )))
                .toList()
            : [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.close, size: 60.0),
                      Text('No orders yet')
                    ],
                  ),
                )
              ]);
  }

  Widget _showSwitch(state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Open'),
        Switch(
          value: _isOpen,
          onChanged: (value) {
            setState(() {
              _isOpen = value;
            });
            _updateShopStatus(state, value);
          },
          activeTrackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        )
      ],
    );
  }

  _updateShopStatus(state, value) async {
    var body = {"isOpen": _isOpen, "phone": state.shop.phone};
    http.Response response = await http.patch(hostUrl + '/api/v0/shop',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.user.jwt}'
        });

    // final responseData = json.decode(response.body);
  }

  _deletOrder(state, id) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${state.user.jwt}"
    };
    print('deleted: $id');
    http.Response response =
        await http.delete(hostUrl + '/api/v0/orders/$id', headers: headers);
    if (response.statusCode == 201) {
      StoreProvider.of<AppState>(context).dispatch(getOrdersAction);
      _showSuccessSnack();
    } else {
      _showErrorSnack(json.decode(response.body)['message']);
    }
  }

  void _showErrorSnack(String error) {
    final snackbar =
        SnackBar(content: Text(error, style: TextStyle(color: Colors.red)));

    _scaffoldKey.currentState.showSnackBar(snackbar);

    // throw Exception('Error registering $error');
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('Successfully removed!',
            style: TextStyle(color: Colors.green)));

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      initialIndex: 0,
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (_, state) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[_showSwitch(state)],
                ),
                bottom: TabBar(
                  labelColor: Colors.deepOrange[600],
                  unselectedLabelColor: Colors.deepOrange[900],
                  tabs: <Widget>[
                    Tab(icon: Icon(Icons.receipt)),
                  ],
                ),
              ),
              body: TabBarView(
                children: <Widget>[_ordersTab(state)],
              ),
            );
          }),
    );
  }
}
