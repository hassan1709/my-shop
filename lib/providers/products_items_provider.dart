import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'product_provider.dart';
import '../models/HttpException.dart';

class ProductItemsProvider with ChangeNotifier {
  List<ProductProvider> _items = [
    // ProductProvider(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl: 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // ProductProvider(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // ProductProvider(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // ProductProvider(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<ProductProvider> get items {
    return [..._items];
  }

  List<ProductProvider> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  ProductProvider findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts() async {
    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        throw HttpException('Could not get the products. There was a problem with the server.');
      }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<ProductProvider> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          ProductProvider(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite'],
          ),
        );

        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
        }),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Could not add the product. There was a problem with the server.');
      }

      final newProduct = ProductProvider(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, ProductProvider product) async {
    final index = _items.indexWhere((prod) => prod.id == id);

    if (index >= 0) {
      var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/$id.json');

      try {
        final response = await http.patch(
          url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }),
        );

        if (response.statusCode >= 400) {
          throw HttpException('Could not update the product. There was a problem with the server.');
        }

        _items[index] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/$id.json');
    try {
      // Deleting is not throwing  error by default.
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        throw HttpException('Could not delete the product. There was a problem in the server.');
      }

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> toggleFavourite(ProductProvider product) async {
    // Updating optimistically
    product.isFavourite = !product.isFavourite;
    notifyListeners();

    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/${product.id}.json');

    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavourite': product.isFavourite,
        }),
      );

      if (response.statusCode >= 400) {
        // product.isFavourite = !product.isFavourite;
        // notifyListeners();
        throw HttpException(
            'Could not set the product as favourite (or no favourite). There was a problem with the server.');
      }
    } catch (error) {
      product.isFavourite = !product.isFavourite;
      notifyListeners();
      throw error;
    }
  }
}
