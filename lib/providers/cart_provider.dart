// FILE: lib/providers/cart_provider.dart
// DESCRIPTION: Cart management with Firestore and size support

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  List<CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  bool get isLoading => _isLoading;

  CartProvider() {
    _listenToCartChanges();
  }

  void _listenToCartChanges() {
    if (currentUserId == null) return;

    _firestore
        .collection('carts')
        .doc(currentUserId)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
          _items =
              snapshot.docs.map((doc) {
                return CartItem.fromMap(doc.id, doc.data());
              }).toList();
          notifyListeners();
        });
  }

  Future<void> addItem(
    Product product, {
    int quantity = 1,
    String? size,
  }) async {
    if (currentUserId == null) return;

    _setLoading(true);

    try {
      // Check if item with same product ID AND same size already exists
      final existingItem = _items.firstWhere(
        (item) => item.productId == product.id && item.size == size,
        orElse:
            () => CartItem(
              id: '',
              productId: '',
              title: '',
              price: 0,
              quantity: 0,
              imageUrl: '',
              userId: '',
              size: '',
            ),
      );

      if (existingItem.id.isNotEmpty) {
        // Update existing item
        final newQuantity = existingItem.quantity + quantity;
        await _firestore
            .collection('carts')
            .doc(currentUserId)
            .collection('items')
            .doc(existingItem.id)
            .update({'quantity': newQuantity});
      } else {
        // Add new item
        final newItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          title:
              size != null && size.isNotEmpty
                  ? '${product.title} (Size: $size)'
                  : product.title,
          price: product.price,
          quantity: quantity,
          imageUrl: product.imageUrl,
          userId: currentUserId!,
          size: size ?? '',
        );

        await _firestore
            .collection('carts')
            .doc(currentUserId)
            .collection('items')
            .doc(newItem.id)
            .set(newItem.toMap());
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error adding to cart: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('carts')
        .doc(currentUserId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (currentUserId == null) return;

    if (newQuantity <= 0) {
      await removeItem(itemId);
    } else {
      await _firestore
          .collection('carts')
          .doc(currentUserId)
          .collection('items')
          .doc(itemId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> updateSize(String itemId, String newSize) async {
    if (currentUserId == null) return;

    // Find the current item
    final currentItem = _items.firstWhere((item) => item.id == itemId);

    // Check if item with same product and new size already exists
    final existingItemIndex = _items.indexWhere(
      (item) =>
          item.id != itemId &&
          item.productId == currentItem.productId &&
          item.size == newSize,
    );

    if (existingItemIndex != -1) {
      // Merge items if same product exists with the new size
      final existingItem = _items[existingItemIndex];

      // Combine quantities
      final combinedQuantity = currentItem.quantity + existingItem.quantity;

      // Update the existing item with combined quantity
      await _firestore
          .collection('carts')
          .doc(currentUserId)
          .collection('items')
          .doc(existingItem.id)
          .update({'quantity': combinedQuantity});

      // Delete the current item
      await removeItem(itemId);
    } else {
      // Just update the size and title
      final newTitle = currentItem.title.replaceAll(
        RegExp(r' \(Size:.*\)'),
        '',
      );
      final updatedTitle =
          newSize.isNotEmpty ? '$newTitle (Size: $newSize)' : newTitle;

      await _firestore
          .collection('carts')
          .doc(currentUserId)
          .collection('items')
          .doc(itemId)
          .update({'size': newSize, 'title': updatedTitle});
    }
  }

  Future<void> clearCart() async {
    if (currentUserId == null) return;

    final batch = _firestore.batch();
    final items =
        await _firestore
            .collection('carts')
            .doc(currentUserId)
            .collection('items')
            .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
