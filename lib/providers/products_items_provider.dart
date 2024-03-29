import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  final String authToken;
  final String userId;

  ProductItemsProvider(this.authToken, this.userId, this._items);

  List<ProductProvider> get items {
    return [..._items];
  }

  List<ProductProvider> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  ProductProvider findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts([bool filterByUser = false]) async {
    _items.clear();
    final filter = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filter');
    try {
      final response = await http.get(url);
      HttpException.validateResponse(response);

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favouritesResponse = await http.get(url);
      HttpException.validateResponse(favouritesResponse);
      final favouriteData = json.decode(favouritesResponse.body) as Map<String, dynamic>;

      final List<ProductProvider> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          ProductProvider(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: favouriteData == null ? false : favouriteData[prodId] ?? false,
          ),
        );

        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      throw HttpException('Could not get the products.\n' + error.toString());
    }
  }

  Future<void> addProduct(ProductProvider product) async {
    final url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      HttpException.validateResponse(response);

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
      throw HttpException('Could not add the product.\n' + error.toString());
    }
  }

  Future<void> updateProduct(String id, ProductProvider product) async {
    final index = _items.indexWhere((prod) => prod.id == id);

    if (index >= 0) {
      final url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

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

        HttpException.validateResponse(response);

        _items[index] = product;
        notifyListeners();
      } catch (error) {
        throw HttpException('Could not update the product.\n' + error.toString());
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    try {
      // Deleting is not throwing  error by default.
      final response = await http.delete(url);

      HttpException.validateResponse(response);

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    } catch (error) {
      throw HttpException('Could not delete the product.\n' + error.toString());
    }
  }

  Future<void> toggleFavourite(ProductProvider product) async {
    // Updating optimistically
    product.isFavourite = !product.isFavourite;
    notifyListeners();

    final url =
        Uri.parse('https://my-shop-90800-default-rtdb.firebaseio.com/products/${product.id}.json?auth=$authToken');

    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavourite': product.isFavourite,
        }),
      );

      HttpException.validateResponse(response);
    } catch (error) {
      product.isFavourite = !product.isFavourite;
      notifyListeners();
      throw HttpException('Could not set the product status.\n' + error.toString());
    }
  }

  Future<void> toggleFavourite2(ProductProvider product, String userId) async {
    // Updating optimistically
    product.isFavourite = !product.isFavourite;
    notifyListeners();

    final url = Uri.parse(
        'https://my-shop-90800-default-rtdb.firebaseio.com/userFavourites/$userId/${product.id}.json?auth=$authToken');

    try {
      final response = await http.put(
        url,
        body: json.encode(
          product.isFavourite,
        ),
      );

      HttpException.validateResponse(response);
    } catch (error) {
      product.isFavourite = !product.isFavourite;
      notifyListeners();
      throw HttpException('Could not set the product status.\n' + error.toString());
    }
  }
}
