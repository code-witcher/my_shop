import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Cart {
  final String id, title, imageUrl;
  final int quantity;
  final double price;
  final DateTime date;

  Cart({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.date,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, Cart> _cart = {};

  Map<String, Cart> get carts {
    return {..._cart};
  }

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
        'carts.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    Map<String, Cart> _loadedData = {};
    final data = json.decode(response.body) as Map<String, dynamic>;

    data.forEach((prodId, cartData) {
      final cart = cartData as Map<String, dynamic>;

      _loadedData.putIfAbsent(
        prodId,
        () => Cart(
          id: cart.keys.toList()[0],
          title: cartData[cart.keys.toList()[0]]['title'],
          price: cartData[cart.keys.toList()[0]]['price'],
          quantity: cartData[cart.keys.toList()[0]]['quantity'],
          imageUrl: cartData[cart.keys.toList()[0]]['imageUrl'],
          date: DateTime.parse(cartData[cart.keys.toList()[0]]['date']),
        ),
      );
    });
    _cart = _loadedData;
    notifyListeners();
  }

  Future<void> addItem(
      {required String productId,
      required String title,
      required String imageUrl,
      required double price}) async {
    final dateNow = DateTime.now();
    if (_cart.containsKey(productId)) {
      final url = Uri.parse(
          'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
          'carts/$productId/${_cart[productId]?.id}.json');

      final response = await http.patch(url,
          body: json.encode({'quantity': _cart[productId]!.quantity + 1}));
      if (!(response.statusCode >= 400)) {
        _cart.update(
          productId,
          (oldValue) => Cart(
            id: oldValue.id,
            title: oldValue.title,
            price: oldValue.price,
            quantity: oldValue.quantity + 1,
            imageUrl: oldValue.imageUrl,
            date: oldValue.date,
          ),
        );
      } else {
        throw const HttpException('Error updating the cart in cart_provider:');
      }
    } else {
      final url = Uri.parse(
          'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
          'carts/$productId.json');
      final response = await http.post(
        url,
        body: json.encode({
          'title': title,
          'price': price,
          'quantity': 1,
          'imageUrl': imageUrl,
          'date': dateNow.toIso8601String(),
        }),
      );
      _cart.putIfAbsent(
        productId,
        () => Cart(
          id: json.decode(response.body)['name'],
          title: title,
          price: price,
          quantity: 1,
          imageUrl: imageUrl,
          date: dateNow,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> delete(String productId) async {
    final url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
        'carts/$productId/${_cart[productId]?.id}.json');

    if (_cart.containsKey(productId)) {
      final response = await http.delete(url);
      if (!(response.statusCode >= 400)) {
        _cart.remove(productId);
        notifyListeners();
      } else {
        throw const HttpException('Error deleting the cart in cart_provider:');
      }
    }
  }

  Future<void> deleteOneItem(String productId) async {
    final url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
        'carts/$productId/${_cart[productId]?.id}.json');
    if (!_cart.containsKey(productId)) {
      return;
    }
    if (_cart[productId]!.quantity > 1) {
      final response = await http.patch(url,
          body: json.encode({'quantity': _cart[productId]!.quantity - 1}));
      if (!(response.statusCode >= 400)) {
        _cart.update(
          productId,
          (oldValue) => Cart(
            id: oldValue.id,
            title: oldValue.title,
            price: oldValue.price,
            quantity: oldValue.quantity - 1,
            imageUrl: oldValue.imageUrl,
            date: oldValue.date,
          ),
        );
      } else {
        throw const HttpException('Error deleting the cart in cart_provider:');
      }
    } else {
      final response = await http.delete(url);
      if (!(response.statusCode >= 400)) {
        _cart.remove(productId);
      } else {
        throw const HttpException('Error deleting the cart in cart_provider:');
      }
    }
    notifyListeners();
  }

  int get count {
    int count = 0;
    _cart.forEach((key, value) {
      count += value.quantity;
    });
    return count;
  }

  double get totalPrice {
    double total = 0;
    _cart.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  Future<void> clearCart() async {
    final url = Uri.parse(
        'https://glitter-15a40-default-rtdb.europe-west1.firebasedatabase.app/'
        'carts.json');
    final response = await http.delete(url);
    if (!(response.statusCode >= 400)) {
      _cart.clear();
      notifyListeners();
    } else {
      throw const HttpException('Error deleting the cart in cart_provider:');
    }
  }
}
