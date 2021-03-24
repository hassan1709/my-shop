import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../providers/cart_items_provider.dart';
import '../models/order.dart';
import '../models/cart.dart';
import '../models/HttpException.dart';

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> addOrder(
    List<Cart> cartProducts,
    double total,
  ) async {
    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/orders.json');
    final timestamp = DateTime.now();

    try {
      final body = json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
      });

      print(body);

      final response = await http.post(url, body: body);

      if (response.statusCode >= 400) {
        throw HttpException('Could not add the order. There was a problem with the server.');
      }

      _orders.insert(
          0,
          Order(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: timestamp,
            products: cartProducts,
          ));

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
