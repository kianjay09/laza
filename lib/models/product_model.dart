import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  double rating;
  int reviewCount;
  final int stock;
  final List<String> sizes; // 🔥 NEW
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.stock = 99,
    this.sizes = const [], // 🔥 default empty
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'sizes': sizes, // 🔥 SAVE TO FIRESTORE
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    // ✅ Safe Date conversion
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    // 🔥 SAFE SIZE PARSING
    List<String> sizes = [];
    if (map['sizes'] != null) {
      sizes = List<String>.from(map['sizes']);
    }

    return Product(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      stock: map['stock'] ?? 99,
      sizes: sizes, // 🔥 APPLY
      createdAt: createdAt,
    );
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    int? stock,
    List<String>? sizes, // 🔥 NEW
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes, // 🔥 KEEP VALUE
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
