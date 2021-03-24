import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_items_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/cart_item.dart';
import 'orders_screen.dart';
import '../widgets/error_dialog.dart';

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
                  OrderButton(
                    cartItemsProvider: cartItemsProvider,
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

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartItemsProvider,
  }) : super(key: key);

  final CartItemsProvider cartItemsProvider;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cartItemsProvider.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              try {
                setState(() {
                  _isLoading = true;
                });

                await Provider.of<OrdersProvider>(context, listen: false).addOrder(
                  widget.cartItemsProvider.items.values.toList(),
                  widget.cartItemsProvider.totalAmount,
                );

                setState(() {
                  _isLoading = false;
                });
                widget.cartItemsProvider.clear();
                Navigator.of(context).pushNamed(OrdersScreen.routeName);
              } catch (error) {
                await ErrorDialog.showErrorDialog(context, error.toString());
              }
            },
      // textColor: Theme.of(context).primaryColor,
      style: TextButton.styleFrom(primary: Theme.of(context).primaryColor),
    );
  }
}
