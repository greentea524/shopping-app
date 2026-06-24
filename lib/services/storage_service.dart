import 'dart:convert';

import 'package:flutter_shop/models/order_record.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const String _boxName = 'orders_box';
  late Box<String> _ordersBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _ordersBox = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveOrder(OrderRecord order) async {
    final json = jsonEncode(order.toJson());
    await _ordersBox.put('order_${order.id}', json);
  }

  Future<List<OrderRecord>> getAllOrders() async {
    final orders = <OrderRecord>[];
    for (final value in _ordersBox.values) {
      try {
        final decoded = jsonDecode(value) as Map<String, dynamic>;
        orders.add(OrderRecord.fromJson(decoded));
      } catch (e) {
        // Skip malformed entries
      }
    }
    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders;
  }

  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final key = 'order_$id';
    final jsonString = _ordersBox.get(key);
    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final order = OrderRecord.fromJson(decoded);
        order.status = status;
        await saveOrder(order);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> updateTrackingStatus(String id, TrackingStatus status) async {
    final key = 'order_$id';
    final jsonString = _ordersBox.get(key);
    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final order = OrderRecord.fromJson(decoded);
        order.trackingStatus = status;
        await saveOrder(order);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> deleteOrder(String id) async {
    await _ordersBox.delete('order_$id');
  }

  Future<void> clearAllOrders() async {
    await _ordersBox.clear();
  }
}

