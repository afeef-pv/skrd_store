import 'dart:convert';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:silkraod_store/globals.dart';
import 'package:silkraod_store/models/address.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/models/order.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:map_launcher/map_launcher.dart';
import 'package:share/share.dart';
import 'package:silkraod_store/redux/actions.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;
  OrderDetailPage({this.order});
  OrderDetailPageState createState() => OrderDetailPageState();
}

class OrderDetailPageState extends State<OrderDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting;
  Order order;
  Address _address;
  String _orderDetails = '*Order details*\n';
  var availableMaps;
  @override
  void initState() {
    super.initState();
    order = widget.order;
    _loadAddress(order.userId);
  }

  _loadAddress(userId) async {
    http.Response response =
        await http.get(hostUrl + '/api/v0/address/$userId');
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      List<Address> addresses = [];
      responseData.forEach((addressJson) {
        addresses.add(Address.fromJson(addressJson));
      });
      setState(() {
        _address = addresses[0];
      });
    }
  }

  Widget _acceptButton() {
    return order.status == 0
        ? StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: <Widget>[
                      _isSubmitting == true
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              child: Text('Accept'),
                              elevation: 8.0,
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0))),
                              onPressed: () => _updateStatus(state, 1),
                            )
                    ],
                  ));
            })
        : _completeButton();
  }

  Widget _completeButton() {
    return order.status == 1
        ? StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: <Widget>[
                      _isSubmitting == true
                          ? CircularProgressIndicator()
                          : RaisedButton(
                              child: Text('Complete'),
                              elevation: 8.0,
                              color: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0))),
                              onPressed: () => _updateStatus(state, 2),
                            )
                    ],
                  ));
            })
        : Center(child: Text('Completed'));
  }

  _openMapButton() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            _isSubmitting == true
                ? CircularProgressIndicator()
                : RaisedButton(
                    child: Text('Open in Maps'),
                    elevation: 8.0,
                    color: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    onPressed: () => _openMap(),
                  )
          ],
        ));
  }

  _shareOrderButton() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            _isSubmitting == true
                ? CircularProgressIndicator()
                : RaisedButton(
                    child: Text('Share order details'),
                    elevation: 8.0,
                    color: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    onPressed: () => _shareOrder(),
                  )
          ],
        ));
  }

  _shareOrder() {
    if (_address != null) {
      int i = 1;
      order.items.forEach((item) {
        _orderDetails +=
            '$i. ${item.name} x ${item.count}: Rs. ${item.price}/-\n';
        ++i;
      });
      var cords = _address.cords();
      _orderDetails += '\n\n*Name: ${_address.name}*\n';
      _orderDetails += 'Phone: ${_address.phone}\n';
      _orderDetails += 'House Name: ${_address.houseName}\n';
      _orderDetails += 'Locality: ${_address.locality}\n';
      _orderDetails += 'PIN: ${_address.pin}\n\n';
      _orderDetails += 'Total No. of items: ${order.items.length}\n';
      _orderDetails += '*Total Price: Rs. ${order.price}*/-\n';
      _orderDetails +=
          '\nLocation\n https://www.google.com/maps/search/?api=1&query=${cords[0]},${cords[1]}';
      Share.share(_orderDetails);
    }
  }

  _openMap() async {
    availableMaps = await MapLauncher.installedMaps;
    if (_address != null) {
      var cords = _address.cords();
      await availableMaps.first.showMarker(
        coords: Coords(cords[0], cords[1]),
        title: "${_address.name}'s location",
      );
    }
  }

  _updateStatus(state, statusCode) async {
    setState(() {
      _isSubmitting = false;
    });
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${state.user.jwt}"
    };
    var body = {"id": order.id, "status": statusCode};
    http.Response response = await http.patch(hostUrl + '/api/v0/orders/',
        body: json.encode(body), headers: headers);
    if (response.statusCode == 201) {
      setState(() {
        order.status = statusCode;
        StoreProvider.of<AppState>(context).dispatch(getOrdersAction);
        _isSubmitting = false;
      });
    }
  }

  Widget _showItems() {
    List<Widget> items = order.items.map<Widget>((item) {
      return Padding(
          padding: EdgeInsets.all(10.0),
          child: ListTile(
            title: Text('${item.name} x ${item.count}'),
            subtitle: Text('Rs. ${item.price}/-'),
            leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.attach_money)),
          ));
    }).toList();
    List<Widget> children = [];
    if (_address != null) {
      children.add(Padding(
          padding: EdgeInsets.all(10), child: Text('Name: ${_address.name}')));
      children.add(Padding(
          padding: EdgeInsets.all(10),
          child: Text('Phone: ${_address.phone}')));
      children.add(Padding(
          padding: EdgeInsets.all(10),
          child: Text('Address: ${_address.locality}')));
    }
    children.addAll(items);

    children.add(_acceptButton());
    children.add(_openMapButton());
    children.add(_shareOrderButton());
    return ListView(children: children);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(DateFormat('MMM dd - hh:mm').format(order.createdAt) +
            ': Rs.${order.price}/-'),
        centerTitle: true,
      ),
      body: Container(child: _showItems()),
    );
  }
}
