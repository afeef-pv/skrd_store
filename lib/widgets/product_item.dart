import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/pages/edit_product_page.dart';
import 'package:silkraod_store/pages/product_detail_page.dart';

class ProductItem extends StatelessWidget {
  final dynamic item;

  ProductItem({this.item});
  @override
  Widget build(BuildContext context) {
    final String picUrl = item.imageUrl;
    return InkWell(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return ProductDetailPage(item: item);
      })),
      child: GridTile(
          footer: GridTileBar(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                item.name,
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            subtitle: Text(
              '₹ ${item.price}',
              style: TextStyle(fontSize: 16.0),
            ),
            backgroundColor: Color(0xBB000000),
            trailing: StoreConnector<AppState, AppState>(
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
                        })
                    : Text('');
              },
            ),
          ),
          child: Hero(
              tag: item,
              child: Image.network(
                picUrl,
                fit: BoxFit.cover,
              ))),
    );
  }
}
