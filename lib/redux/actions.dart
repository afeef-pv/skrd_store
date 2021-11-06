import 'dart:convert';

import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/models/order.dart';
import 'package:silkraod_store/models/product.dart';
import 'package:silkraod_store/models/shop.dart';
import 'package:silkraod_store/models/user.dart';

import '../globals.dart';

/*user actions */

ThunkAction<AppState> getUserAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final storedUser = prefs.getString('user');
  final user =
      storedUser != null ? User.fromJson(json.decode(storedUser)) : null;
  store.dispatch(GetUserAction(user));
};

class GetUserAction {
  final User _user;

  User get user => this._user;

  GetUserAction(this._user);
}

// shop axns
ThunkAction<AppState> getShopAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final storedShop = prefs.getString('shop');
  final shop = Shop.fromJson(json.decode(storedShop));
  store.dispatch(GetShopAction(shop));
};

class GetShopAction {
  final Shop _shop;
  GetShopAction(this._shop);
  Shop get shop => this._shop;
}

/*Products Axn */
ThunkAction<AppState> getProductsAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  final storedShop = prefs.getString('shop');
  if (storedShop != null) {
    final stored = json.decode(storedShop);
    String phone = stored["phone"];
    http.Response response =
        await http.get('$hostUrl/api/v0/item/items/$phone');
    final responseData = json.decode(response.body);
    List<Product> products = [];
    responseData.forEach((element) {
      final Product product = Product.fromJson(element);
      products.add(product);
    });
    store.dispatch(GetProductsAction(products));
  }
};

class GetProductsAction {
  final List<Product> _products;

  List<Product> get products => this._products;

  GetProductsAction(this._products);
}

// order actions

ThunkAction<AppState> getOrdersAction = (Store<AppState> store) async {
  final String phone = store.state.user.phone;
  if (phone != null) {
    http.Response response =
        await http.get(hostUrl + '/api/v0/orders/store/$phone');
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      List<Order> orders = [];
      responseData.forEach((json) {
        orders.add(Order.fromJson(json));
      });
      store.dispatch(GetOrdersAction(orders));
    }
  }
};

class GetOrdersAction {
  List<Order> _orders;
  List<Order> get orders => this._orders;
  GetOrdersAction(this._orders);
}

// Logout action

ThunkAction<AppState> logoutAction = (Store<AppState> store) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('user');
  await prefs.remove('shop');
  User user;
  store.dispatch(LogoutAction(user));
};

class LogoutAction {
  User _user;
  User get user => this._user;

  LogoutAction(this._user);
}
