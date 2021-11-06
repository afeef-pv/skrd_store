import 'dart:convert';
import 'package:location/location.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:silkraod_store/globals.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreCreatePage extends StatefulWidget {
  final void Function() onInit;
  StoreCreatePage({this.onInit});
  StoreCreatePageState createState() => StoreCreatePageState();
}

class StoreCreatePageState extends State<StoreCreatePage> {
  void initState() {
    super.initState();
    widget.onInit();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  String _storeName, _typeVal = 'Grocery';
  bool _isSubmitting;
  int _type = 0;
  LocationData _locationData;
  Future _initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
      _grantPermission();
    }
  }

  Future _grantPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
  }

  Widget _showStoreName() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _storeName = val,
            validator: (val) => val.length < 3 ? 'Store name too short' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Store Name',
                hintText: 'Enter store name',
                icon: Icon(
                  Icons.people,
                  color: Colors.grey,
                ))));
  }

  Widget _dropDown() {
    return Row(
      children: <Widget>[
        Text(_typeVal),
        DropdownButton<String>(
          items: <String>['Grocery', 'Fish', 'Meat'].map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) => _setType(value),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _showSubmitButton(state) {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            _isSubmitting == true
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  )
                : RaisedButton(
                    child: Text(
                      'Submit',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.black),
                    ),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _submit(state),
                  )
          ],
        ));
  }

  _setType(type) {
    if (type == 'Grocery') {
      setState(() {
        _type = 0;
        _typeVal = 'Grocery';
      });
    } else if (type == 'Fish') {
      setState(() {
        _type = 1;
        _typeVal = 'Fish';
      });
    } else if (type == 'Meat') {
      setState(() {
        _type = 2;
        _typeVal = 'Meat';
      });
    }
  }

  _submit(state) {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      _createShop(state.user);
    } else {
      print('invalid form');
    }
  }

  _createShop(user) async {
    await _initLocation();
    await _grantPermission();
    if (location == null) {
      return;
    }
    setState(() => _isSubmitting = true);
    String latlng = '${_locationData.latitude}, ${_locationData.longitude}';
    var body = {
      "name": _storeName,
      "phone": user.phone,
      "imageUrl": user.phone,
      "location": latlng,
      "catId": _type
    };
    http.Response response = await http.post(hostUrl + '/api/v0/shop',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.jwt}'
        },
        body: json.encode(body));
    setState(() => _isSubmitting = false);
    if (response.statusCode == 201) {
      //store as shared prefs
      _storeShopData(json.decode(response.body));
      _showSuccessSnack();
      //redirect to store
      Navigator.pushReplacementNamed(context, '/store');
    } else {
      _showErrorSnack(json.decode(response.body)['message']);
    }
  }

  void _storeShopData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('shop', json.encode(responseData));
  }

  void _showErrorSnack(String error) {
    final snackbar =
        SnackBar(content: Text(error, style: TextStyle(color: Colors.red)));

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('Shop successfully created!',
            style: TextStyle(color: Colors.green)));

    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Set up a Store"),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: SingleChildScrollView(
                    child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Text('Create Store'),
                      _showStoreName(),
                      _dropDown(),
                      _showSubmitButton(state)
                    ],
                  ),
                )),
              ),
            ),
          );
        });
  }
}
