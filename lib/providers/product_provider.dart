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

  Future<void> toggleFavorites() async {
    final url = Uri.parse('https://glitter-15a40-default-rtdb.europe-west1.'
        'firebasedatabase.app/products/$id.json');
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.patch(
      url,
      body: json.encode({
        'isFavorite': isFavorite,
      }),
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

  List<Product> get products {
    return [..._products];
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/products.json');

    final response = await http.get(url);
    final data = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> _loadedProducts = [];
    // this is to be safe from errors if there was nothing on the server.
    if (data == null) {
      return;
    }
    data.forEach((key, value) {
      _loadedProducts.add(
        Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['image'],
            isFavorite: value['isFavorite']),
      );
    });
    _products = _loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product newProduct) async {
    final url = Uri.parse(
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/products.json',
    );
    final response = await http.post(
      url,
      body: json.encode(
        {
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'image': newProduct.imageUrl,
          'isFavorite': newProduct.isFavorite,
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
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json',
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
          'An error occurred updation an item on product_provider');
    } else {
      final prodIndex = _products.indexWhere((prod) => prod.id == id);
      _products[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json',
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
