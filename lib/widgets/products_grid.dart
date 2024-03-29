import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_item.dart';
import '../providers/products_items_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductItemsProvider>(context);
    final products = showFavs ? productsData.favouriteItems : productsData.items;
    return products.length <= 0
        ? Center(
            child: Text(
              'No Products Available.',
              style: TextStyle(fontSize: 30),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: products.length,
            //Calling the constructor ChangeNotifierProvider.value is more efficient when working with lists or grids (existing objects in use)
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              //create: (c) => products[i],
              value: products[i],
              child: ProductItem(),
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          );
  }
}
