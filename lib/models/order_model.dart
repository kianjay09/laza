// FILE: lib/models/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt; // Change from dateTime to createdAt
  final String address;
  final String city;
  final String zipCode;
  final String paymentMethod;
  final String userId;
  String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt, // Change from dateTime to createdAt
    required this.address,
    required this.city,
    required this.zipCode,
    required this.paymentMethod,
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ), // Change from dateTime to createdAt
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'status': status,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final itemsList =
        (map['items'] as List? ?? [])
            .map((e) => CartItem.fromMap(e['id'] ?? '', e))
            .toList();

    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    return OrderModel(
      id: id,
      items: itemsList,
      total: (map['total'] ?? 0).toDouble(),
      createdAt: createdAt, // Change from dateTime to createdAt
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      zipCode: map['zipCode'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'Pending',
    );
  }
}
