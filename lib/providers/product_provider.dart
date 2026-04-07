// FILE: lib/providers/product_provider.dart
// DESCRIPTION: Product management with PHP prices and local asset images

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    _loadProductsFromFirestore();
  }

  void _loadProductsFromFirestore() {
    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('products')
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              _products =
                  snapshot.docs.map((doc) {
                    return Product.fromMap(doc.id, doc.data());
                  }).toList();
            } else {
              _loadDemoProducts();
              _addDemoProductsToFirestore();
            }

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _loadDemoProducts();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _loadDemoProducts() {
    _products = [
      // Nike Shoes - Using local asset images
      Product(
        id: 'nike_air_max_90',
        title: 'Nike Air Max 90',
        description:
            'Iconic running shoe with visible Air cushioning and timeless design. Perfect for daily wear and casual style.',
        price: 7299.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_air_max.jpg',
        rating: 4.8,
        reviewCount: 2456,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_air_jordan_1',
        title: 'Nike Air Jordan 1 Mid',
        description:
            'Legendary basketball sneaker that transcends the court. Premium leather upper with iconic Air Jordan wings logo.',
        price: 9999.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_air_jordan.jpg',
        rating: 4.9,
        reviewCount: 3456,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_air_force_1',
        title: 'Nike Air Force 1',
        description:
            'Classic white leather sneaker that never goes out of style. The ultimate streetwear essential.',
        price: 6499.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_air_force.jpg',
        rating: 4.8,
        reviewCount: 5678,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_air_max_97',
        title: 'Nike Air Max 97',
        description:
            'Modern design with full-length Air cushioning for ultimate comfort. Sleek and stylish.',
        price: 8999.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_air_max_97.jpg',
        rating: 4.7,
        reviewCount: 1890,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_revolution',
        title: 'Nike Revolution 6',
        description:
            'Lightweight and breathable running shoes with soft cushioning for everyday wear.',
        price: 3999.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_revolution.jpg',
        rating: 4.6,
        reviewCount: 1234,
        createdAt: DateTime.now(),
      ),

      // Nike Jackets
      Product(
        id: 'nike_tech_fleece',
        title: 'Nike Sportswear Tech Fleece Jacket',
        description:
            'Premium fleece jacket with modern design. Stay warm and stylish with zippered pockets and ribbed cuffs.',
        price: 8999.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_tech_fleece.jpg',
        rating: 4.7,
        reviewCount: 1234,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_hoodie',
        title: 'Nike Club Fleece Hoodie',
        description:
            'Classic pullover hoodie with soft fleece lining. Perfect for everyday comfort.',
        price: 4999.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_hoodie.jpg',
        rating: 4.7,
        reviewCount: 2345,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'nike_windrunner',
        title: 'Nike Windrunner Jacket',
        description:
            'Iconic windbreaker with chevron design. Lightweight and water-resistant.',
        price: 6499.00,
        category: 'Nike',
        imageUrl: 'assets/images/products/nike_windrunner.jpg',
        rating: 4.6,
        reviewCount: 876,
        createdAt: DateTime.now(),
      ),

      // Other Products
      Product(
        id: 'minimalist_watch',
        title: 'Minimalist Watch',
        description:
            'Elegant minimalist design watch with leather strap. Perfect for formal occasions.',
        price: 3499.00,
        category: 'Watches',
        imageUrl: 'assets/images/products/watch.jpg',
        rating: 4.5,
        reviewCount: 128,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'wireless_headphones',
        title: 'Wireless Headphones',
        description:
            'Noise cancelling over-ear headphones with 30hr battery life. Premium sound quality.',
        price: 5499.00,
        category: 'Electronics',
        imageUrl: 'assets/images/products/headphones.jpg',
        rating: 4.8,
        reviewCount: 342,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'cotton_tshirt',
        title: 'Cotton T-Shirt',
        description:
            'Comfortable 100% cotton t-shirt, available in multiple colors. Breathable and soft.',
        price: 899.00,
        category: 'Clothing',
        imageUrl: 'assets/images/products/tshirt.jpg',
        rating: 4.2,
        reviewCount: 89,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'smart_backpack',
        title: 'Smart Backpack',
        description:
            'Water-resistant backpack with USB charging port. Perfect for students and professionals.',
        price: 2499.00,
        category: 'Accessories',
        imageUrl: 'assets/images/products/backpack.jpg',
        rating: 4.6,
        reviewCount: 201,
        createdAt: DateTime.now(),
      ),
      Product(
        id: 'coffee_maker',
        title: 'Coffee Maker',
        description:
            'Programmable coffee maker with thermal carafe. Brew delicious coffee every morning.',
        price: 3999.00,
        category: 'Home',
        imageUrl: 'assets/images/products/coffee_maker.jpg',
        rating: 4.4,
        reviewCount: 167,
        createdAt: DateTime.now(),
      ),
    ];
    _filteredProducts = [];
    notifyListeners();
  }

  Future<void> _addDemoProductsToFirestore() async {
    for (var product in _products) {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toMap());
    }
  }

  void filterByCategory(String? category) {
    if (category == null || category == 'All') {
      _filteredProducts = [];
    } else {
      _filteredProducts =
          _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await _firestore
        .collection('products')
        .doc(updatedProduct.id)
        .update(updatedProduct.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  List<String> getCategories() {
    final categories = _products.map((p) => p.category).toSet().toList();
    return ['All', ...categories];
  }
}
