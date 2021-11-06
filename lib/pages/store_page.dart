import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:silkraod_store/models/app_state.dart';
import 'package:silkraod_store/redux/actions.dart';
import 'package:silkraod_store/widgets/product_item.dart';

final gradientBackground = BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topRight, stops: [
  0.1,
  0.3,
  0.5,
  0.7,
  0.9
], colors: [
  Colors.deepOrange[700],
  Colors.deepOrange[600],
  Colors.deepOrange[500],
  Colors.deepOrange[400],
  Colors.deepOrange[300]
]));

class StorePage extends StatefulWidget {
  final void Function() onInit;
  StorePage({this.onInit});

  @override
  StorePageState createState() => StorePageState();
}

class StorePageState extends State<StorePage> {
  void initState() {
    super.initState();
    widget.onInit();
  }

  final _appBar = PreferredSize(
    preferredSize: Size.fromHeight(60.0),
    child: StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return AppBar(
          centerTitle: true,
          title: SizedBox(
              child: state.user != null
                  ? Text(state.shop.name)
                  : FlatButton(
                      child: Text('Register Here',
                          style: Theme.of(context).textTheme.bodyText1),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    )),
          leading: state.user != null
              ? IconButton(
                  icon: Icon(Icons.store),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                )
              : Text(''),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: StoreConnector<AppState, VoidCallback>(
                converter: (store) {
                  return () => _logoutAction(context, store);
                },
                builder: (_, callback) {
                  print(state.user);
                  return state.user != null
                      ? IconButton(
                          icon: Icon(Icons.exit_to_app), onPressed: callback)
                      : Text('');
                },
              ),
            )
          ],
        );
      },
    ),
  );

  static void _logoutAction(context, store) {
    Navigator.pushReplacementNamed(context, '/');
    store.dispatch(logoutAction);
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/addProduct'),
        ),
        appBar: _appBar,
        body: Container(
          decoration: gradientBackground,
          child: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (_, state) {
              return Column(children: <Widget>[
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: GridView.builder(
                      itemCount: state.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                          crossAxisCount:
                              orientation == Orientation.portrait ? 2 : 3,
                          childAspectRatio:
                              orientation == Orientation.portrait ? 1.0 : 1.3),
                      itemBuilder: (context, index) => ProductItem(
                        item: state.products[index],
                      ),
                    ),
                  ),
                )
              ]);
            },
          ),
        ));
  }
}
