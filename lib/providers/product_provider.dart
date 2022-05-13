import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id, title, description, imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorites(String? token, String? userId) async {
    final url = Uri.parse('https://glitter-15a40-default-rtdb.europe-west1.'
        'firebasedatabase.app/userFav/$userId/$id.json?auth=$token');
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.put(
      url,
      body: json.encode(isFavorite),
    );
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw const HttpException('Error occured on updating favorite satus');
    }
  }
}

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];
  String? _token;
  String? _userId;

  List<Product> get products {
    return [..._products];
  }

  void update(String? token, String? userId, List<Product> products) {
    _products = products;
    _token = token;
    _userId = userId;
  }

  Future<void> fetchProducts([bool filter = false]) async {
    final segmentFilter =
        filter ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
        'products.json?auth=$_token&$segmentFilter');

    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data == null) {
      return;
    }

    url = Uri.parse('https://glitter-15a40-default-rtdb.europe-west1.'
        'firebasedatabase.app/userFav/$_userId.json?auth=$_token');
    final fav = await http.get(url);

    final userFav = json.decode(fav.body);

    final List<Product> _loadedProducts = [];
    // this is to be safe from errors if there was nothing on the server.

    data.forEach((prodId, value) {
      _loadedProducts.add(
        Product(
          id: prodId,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['image'],
          isFavorite: userFav == null ? false : userFav[prodId] ?? false,
        ),
      );
    });
    _products = _loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product newProduct) async {
    final url = Uri.parse(
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
      'products.json?auth=$_token',
    );
    final response = await http.post(
      url,
      body: json.encode(
        {
          'creatorId': _userId,
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'image': newProduct.imageUrl,
        },
      ),
    );
    print(json.decode(response.body));
    _products.add(
      Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      ),
    );
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.parse(
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
      'products/$id.json?auth=$_token',
    );
    final response = await http.patch(
      url,
      body: json.encode({
        'title': newProduct.title,
        'price': newProduct.price,
        'description': newProduct.description,
        'image': newProduct.imageUrl,
      }),
    );
    if (response.statusCode >= 400) {
      throw const HttpException(
          'An error occurred updating an item on product_provider');
    } else {
      final prodIndex = _products.indexWhere((prod) => prod.id == id);
      _products[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
      'products/$id.json?auth=$_token',
    );
    final prodIndex = _products.indexWhere((prod) => prod.id == id);
    dynamic excitingProd = _products[prodIndex];
    _products.removeAt(prodIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _products.insert(prodIndex, excitingProd);
      notifyListeners();
      throw const HttpException('Error deleting an item on product_provider');
    } else {
      excitingProd = null;
    }
  }

  Product findById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }
}
