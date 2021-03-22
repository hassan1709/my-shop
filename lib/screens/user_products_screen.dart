import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_items_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/error_dialog.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      // No need to listen to changes at this point
      await Provider.of<ProductItemsProvider>(context, listen: false).getProducts();
    } catch (error) {
      await ErrorDialog.showErrorDialog(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductItemsProvider products = Provider.of<ProductItemsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              //Navigator.pushNamed(context, EditProductScreen.routeName);
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: products.items.length <= 0
            ? Center(
                child: Text(
                  'No Products Available.',
                  style: TextStyle(fontSize: 30),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: products.items.length,
                  itemBuilder: (_, i) => Column(
                    children: <Widget>[
                      UserProductItem(
                        products.items[i].id,
                        products.items[i].title,
                        products.items[i].imageUrl,
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
