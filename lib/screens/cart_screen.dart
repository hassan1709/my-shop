import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_items_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cartItemsProvider = Provider.of<CartItemsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartItemsProvider.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: Theme.of(context).primaryTextTheme.headline6.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: Text('ORDER NOW'),
                    onPressed: () {
                      Provider.of<OrdersProvider>(context, listen: false).addOrder(
                        cartItemsProvider.items.values.toList(),
                        cartItemsProvider.totalAmount,
                      );
                      cartItemsProvider.clear();
                      Navigator.of(context).pushNamed(OrdersScreen.routeName);
                    },
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItemsProvider.itemCount,
              itemBuilder: (ctx, i) => CartItem(
                cartItemsProvider.items.values.toList()[i].id,
                cartItemsProvider.items.keys.toList()[i],
                cartItemsProvider.items.values.toList()[i].price,
                cartItemsProvider.items.values.toList()[i].quantity,
                cartItemsProvider.items.values.toList()[i].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
