import 'package:meta/meta.dart';
import 'package:silkraod_store/models/shop.dart';

import 'order.dart';
import 'product.dart';

@immutable
class AppState {
  final dynamic user;
  final Shop shop;
  final List<Product> products;
  final List<Order> orders;

  AppState(
      {@required this.user,
      @required this.shop,
      @required this.products,
      @required this.orders});

  factory AppState.initial() {
    return AppState(user: null, shop: null, products: [], orders: []);
  }
}
