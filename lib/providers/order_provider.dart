import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/providers/cart_provider.dart';

class Order {
  final String id;
  final double total;
  final DateTime date;
  final List<Cart> carts;

  Order({
    required this.id,
    required this.total,
    required this.date,
    required this.carts,
  });
}

class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse('https://glitter-15a40-default-rtdb.europe-west1.'
        'firebasedatabase.app/orders.json');
    final response = await http.get(url);
    if (json.decode(response.body) == null) {
      return;
    }
    final data = json.decode(response.body) as Map<String, dynamic>;

    final List<Order> _loadedData = [];
    data.forEach((orderId, value) {
      _loadedData.insert(
          0,
          Order(
            id: orderId,
            total: value['total'],
            date: DateTime.parse(value['date']),
            carts: (value['carts'] as List<dynamic>)
                .map((cartItem) => Cart(
                    id: cartItem['id'],
                    title: cartItem['title'],
                    price: cartItem['price'],
                    quantity: cartItem['quantity'],
                    imageUrl: cartItem['image'],
                    date: DateTime.parse(
                      cartItem['date'],
                    )))
                .toList(),
          ));
    });
    _orders = _loadedData;
    notifyListeners();
  }

  Future<void> addOrder({
    required double total,
    required List<Cart> carts,
  }) async {
    final url = Uri.parse('https://glitter-15a40-default-rtdb.europe-west1.'
        'firebasedatabase.app/orders.json');
    final date = DateTime.now();
    if (total > 0) {
      final response = await http.post(
        url,
        body: json.encode({
          'total': total,
          'date': date.toIso8601String(),
          'carts': carts
              .map((cartItem) => {
                    'id': cartItem.id,
                    'title': cartItem.title,
                    'price': cartItem.price,
                    'quantity': cartItem.quantity,
                    'image': cartItem.imageUrl,
                    'date': cartItem.date.toIso8601String(),
                  })
              .toList(),
        }),
      );
      _orders.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          total: total,
          date: date,
          carts: carts,
        ),
      );
    }
  }
}
