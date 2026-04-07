// FILE: lib/providers/order_provider.dart
// Add cancelOrder method

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _listenToOrders();
  }

  void _listenToOrders() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          _orders =
              snapshot.docs.map((doc) {
                return OrderModel.fromMap(doc.id, doc.data());
              }).toList();
          _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          notifyListeners();
        });
  }

  void listenToAllOrdersForAdmin() {
    _firestore.collection('orders').snapshots().listen((snapshot) {
      _orders =
          snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.id, doc.data());
          }).toList();
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    });
  }

  Future<void> addOrder({
    required List<CartItem> items,
    required double total,
    required String address,
    required String city,
    required String zipCode,
    required String paymentMethod,
    required String userId,
  }) async {
    _setLoading(true);

    try {
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      final newOrder = OrderModel(
        id: orderId,
        items: items,
        total: total,
        createdAt: DateTime.now(),
        address: address,
        city: city,
        zipCode: zipCode,
        paymentMethod: paymentMethod,
        userId: userId,
        status: 'Pending',
      );

      await _firestore.collection('orders').doc(orderId).set(newOrder.toMap());
      _orders.insert(0, newOrder);
      notifyListeners();

      _setLoading(false);
    } catch (e) {
      print('Error adding order: $e');
      _setLoading(false);
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  // NEW: Cancel order method
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);

    try {
      // Find the order
      final orderIndex = _orders.indexWhere((o) => o.id == orderId);
      if (orderIndex == -1) {
        _setLoading(false);
        return false;
      }

      final order = _orders[orderIndex];

      // Only allow cancellation if status is Pending or Processing
      if (order.status == 'Pending' || order.status == 'Processing') {
        await _firestore.collection('orders').doc(orderId).update({
          'status': 'Cancelled',
        });
        _orders[orderIndex].status = 'Cancelled';
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('Error cancelling order: $e');
      _setLoading(false);
      return false;
    }
  }

  List<OrderModel> getOrdersByUser(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
