import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/models/order.dart';
import 'package:silkraod_store/models/product.dart';
import 'package:silkraod_store/models/shop.dart';
import 'package:silkraod_store/models/user.dart';

import 'actions.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
      user: userReducer(state.user, action),
      shop: shopReducer(state.shop, action),
      products: productsReducer(state.products, action),
      orders: ordersReducer(state.orders, action));
}

User userReducer(User user, dynamic action) {
  if (action is GetUserAction) {
    return action.user;
  } else if (action is LogoutAction) {
    return action.user;
  }
  return user;
}

Shop shopReducer(Shop shop, dynamic action) {
  if (action is GetShopAction) {
    return action.shop;
  }
  return shop;
}

List<Product> productsReducer(List<Product> products, dynamic action) {
  if (action is GetProductsAction) {
    return action.products;
  }
  return products;
}

List<Order> ordersReducer(List<Order> orders, dynamic action) {
  if (action is GetOrdersAction) {
    return action.orders;
  }
  return orders;
}
