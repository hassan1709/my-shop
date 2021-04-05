import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/products_items_provider.dart';
import 'providers/cart_items_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductItemsProvider>(
          create: (_) => ProductItemsProvider(null, []),
          update: (ctx, auth, prevProds) => ProductItemsProvider(
            auth.token,
            prevProds == null ? [] : prevProds.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartItemsProvider(),
        ),
        ChangeNotifierProxyProvider<Auth, OrdersProvider>(
          create: (_) => OrdersProvider(null, []),
          update: (ctx, auth, prevOrders) => OrdersProvider(
            auth.token,
            prevOrders == null ? [] : prevOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'My Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuth ? ProductOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            // ProductOverviewScreen.routeName: (ctx) => ProductOverviewScreen(),
          },
        ),
      ),
    );
  }
}
