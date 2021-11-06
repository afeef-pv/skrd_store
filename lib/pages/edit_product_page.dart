import 'dart:convert';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/models/product.dart';
import '../globals.dart';

class EditProductPage extends StatefulWidget {
  final Product item;
  EditProductPage({this.item});
  @override
  EditProductPageState createState() => EditProductPageState();
}

class EditProductPageState extends State<EditProductPage> {
  Product item;
  void initState() {
    super.initState();
    item = widget.item;
    _isAvailable = item.isAvailable;
  }

  final _formKey = GlobalKey<FormState>();

  String _name, _price, _quantity, _description;
  File _image;
  bool _isSubmitting = false, _isAvailable;

  Widget _showName() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            initialValue: item.name,
            onSaved: (val) => _name = val,
            validator: (val) => val.length < 3 ? 'Name is too small' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
                hintText: 'Enter product name',
                icon: Icon(
                  Icons.next_week,
                  color: Colors.grey,
                ))));
  }

  Widget _showPrice() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            keyboardType: TextInputType.number,
            initialValue: '${item.price}',
            onSaved: (val) => _price = val,
            validator: (val) => val.length < 1 ? 'price is too small' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Price',
                hintText: 'Enter product price',
                icon: Icon(
                  Icons.euro_symbol,
                  color: Colors.grey,
                ))));
  }

  Widget _showQuantity() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            keyboardType: TextInputType.number,
            initialValue: '${item.quantity}',
            onSaved: (val) => _quantity = val,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
                hintText: 'Enter product quantity',
                icon: Icon(
                  Icons.assessment,
                  color: Colors.grey,
                ))));
  }

  Widget _showDescription() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            initialValue: item.description,
            maxLines: null,
            onSaved: (val) => _description = val,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
                hintText: 'Enter product description',
                icon: Icon(
                  Icons.description,
                  color: Colors.grey,
                ))));
  }

  Widget _showSubmitButton() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  _isSubmitting == true
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text(
                              'Update',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.black),
                            ),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            color: Theme.of(context).accentColor,
                            onPressed: () => _submit(state),
                          )),
                ],
              ));
        });
  }

  Widget _showDeleteButton() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  _isSubmitting == true
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: RaisedButton(
                            child: Text(
                              'Delete',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Colors.black),
                            ),
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            color: Colors.red,
                            onPressed: () => _delete(state.user.jwt, item.id),
                          )),
                ],
              ));
        });
  }

  Widget _showAddImageButton() {
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
                      'Select an Image',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.black),
                    ),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Theme.of(context).accentColor,
                    onPressed: () => _pickImage(),
                  ),
          ],
        ));
  }

  Widget _showSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Available'),
        Switch(
          value: _isAvailable,
          onChanged: (value) {
            item.isAvailable = value;
            setState(() {
              _isAvailable = item.isAvailable;
            });
          },
          activeTrackColor: Colors.lightGreenAccent,
          activeColor: Colors.green,
        )
      ],
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  void _delete(token, id) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    http.Response response =
        await http.delete(hostUrl + '/api/v0/item/$id', headers: headers);
    if (response.statusCode == 201) {
      Navigator.pushReplacementNamed(context, '/store');
    }
  }

  void _submit(state) {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      _createProduct(state);
    } else {
      print('invalid form');
    }
  }

  void _createProduct(state) async {
    setState(() => _isSubmitting = true);
    var body = {
      "id": item.id,
      "name": _name,
      "description": _description,
      "quantity": _quantity,
      "price": _price,
      "imageUrl": _name,
      "catId": 51,
      "shopId": state.shop.phone,
      "isAvailable": _isAvailable
    };
    http.Response response = await http.patch(hostUrl + '/api/v0/item',
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.user.jwt}'
        });

    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      if (_image != null) {
        await _uploadImage(responseData["imageUrl"]);
      }

      Navigator.pushReplacementNamed(context, '/store');
      // StoreProvider.of<AppState>(context).dispatch(getProductsAction);
    } else {
      print('Error: ' + responseData["message"]);
    }
    setState(() => _isSubmitting = false);
  }

  _uploadImage(String url) async {
    var imageBinary = await _image.readAsBytes();
    print(imageBinary.toString());
    http.Response response = await http.put(url,
        headers: {
          'Content-Type': 'image/jpeg',
        },
        body: imageBinary);
    if (response.statusCode == 200) {
      //redirect to new page
    } else {
      print('error: ' + json.decode(response.body)["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add product to store'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
            child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _showAddImageButton(),
                  _showName(),
                  _showPrice(),
                  _showQuantity(),
                  _showDescription(),
                  _showSwitch(),
                  _showSubmitButton(),
                  _showDeleteButton()
                ],
              )),
        )),
      ),
    );
  }
}
