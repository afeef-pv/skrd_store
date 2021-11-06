import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:silkraod_store/models/user.dart';
import 'package:silkraod_store/pages/firebase_fcm.dart';
import 'package:silkraod_store/pages/store_create_page.dart';
import 'models/app_state.dart';
import 'pages/add_product_page.dart';
import 'pages/cart_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/store_page.dart';
import 'redux/actions.dart';
import 'redux/reducers.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState.initial(),
      middleware: [thunkMiddleware, LoggingMiddleware.printer()]);
  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  MyApp({this.store});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
        store: store,
        child: MaterialApp(
            title: 'Silkroad',
            routes: {
              '/store': (BuildContext context) => StorePage(
                    onInit: () {
                      StoreProvider.of<AppState>(context)
                          .dispatch(getUserAction);

                      StoreProvider.of<AppState>(context)
                          .dispatch(getShopAction);
                      StoreProvider.of<AppState>(context)
                          .dispatch(getProductsAction);
                    },
                  ),
              '/': (BuildContext context) => LoginPage(
                    onInit: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final storedUser = prefs.getString('user');
                      if (storedUser != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FirebaseFCM(
                            user: User.fromJson(json.decode(storedUser)),
                          ),
                        ));
                      }
                    },
                  ),
              '/register': (BuildContext context) => RegisterPage(),
              '/cart': (BuildContext context) => CartPage(
                    onInit: () {
                      StoreProvider.of<AppState>(context)
                          .dispatch(getOrdersAction);
                    },
                  ),
              '/addProduct': (BuildContext context) => AddProductPage(),
              '/storeAdd': (BuildContext context) =>
                  StoreCreatePage(onInit: () {
                    StoreProvider.of<AppState>(context).dispatch(getUserAction);
                  })
            },
            theme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Colors.cyan[400],
                accentColor: Colors.deepOrange[200],
                textTheme: TextTheme(
                    headline5:
                        TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                    headline6:
                        TextStyle(fontSize: 22.0, fontStyle: FontStyle.italic),
                    bodyText2: TextStyle(fontSize: 18.0)))));
  }
}
