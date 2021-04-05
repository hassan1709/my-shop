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
  final String authToken;

  OrdersProvider(this.authToken, this._orders);

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> getOrders() async {
    final url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
    try {
      final response = await http.get(url);

      HttpException.validateResponse(response);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<Order> loadedOrders = [];

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          Order(
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) => Cart(
                      id: item['id'],
                      price: item['price'],
                      quantity: item['quantity'],
                      title: item['title'],
                    ))
                .toList(),
          ),
        );

        _orders = loadedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (error) {
      throw HttpException('Could not get the orders.\n' + error.toString());
    }
  }

  Future<void> addOrder(List<Cart> cartProducts, double total) async {
    final url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/orders.json?auth=$authToken');
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

      final response = await http.post(url, body: body);

      HttpException.validateResponse(response);

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
      throw HttpException('Could not create the order.\n' + error.toString());
    }
  }
}
