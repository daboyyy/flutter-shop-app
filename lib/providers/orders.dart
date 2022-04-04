import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get order => [..._orders];

  Future<void> fetchAndSetOrder() async {
    final url = Uri.https(
      'flutter-shop-app-e1643-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders.json',
    );
    final res = await http.get(url);
    final data = json.decode(res.body.toString()) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];
    data.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          id: key,
          amount: value['amount'],
          products: (value['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(value['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
      'flutter-shop-app-e1643-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders.json',
    );
    final timestamp = DateTime.now();
    final res = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((item) => {
                    'id': item.id,
                    'title': item.title,
                    'quantity': item.quantity,
                    'price': item.price,
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(res.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );
  }
}
