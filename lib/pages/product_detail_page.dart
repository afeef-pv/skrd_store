import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/models/product.dart';
import 'package:silkraod_store/pages/store_page.dart';

import 'edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product item;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProductDetailPage({this.item});

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(item.name)),
      body: Container(
        decoration: gradientBackground,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Hero(
                  tag: item,
                  child: Image.network(item.imageUrl,
                      width: orientation == Orientation.portrait ? 600 : 250,
                      height: orientation == Orientation.portrait ? 400 : 200,
                      fit: BoxFit.cover)),
            ),
            Text(item.name, style: Theme.of(context).textTheme.headline5),
            Text(
              'Rs. ${item.price}/-',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              '${item.quantity} left only',
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (_, state) {
                  return state.user != null
                      ? IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return EditProductPage(item: item);
                            }));
                            final snackbar = SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Updated',
                                  style: TextStyle(color: Colors.green)),
                            );
                            _scaffoldKey.currentState.showSnackBar(snackbar);
                          })
                      : Text('');
                },
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                  child: Padding(
                padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0),
                child: Text(item.description),
              )),
            )
          ],
        ),
      ),
    );
  }
}
