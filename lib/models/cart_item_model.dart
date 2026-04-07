// FILE: lib/models/cart_item_model.dart
// DESCRIPTION: Cart item model with size support

class CartItem {
  final String id;
  final String productId;
  String title;
  final double price;
  int quantity;
  final String imageUrl;
  final String userId;
  String size;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.userId,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'userId': userId,
      'size': size,
    };
  }

  factory CartItem.fromMap(String id, Map<String, dynamic> map) {
    return CartItem(
      id: id,
      productId: map['productId'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      imageUrl: map['imageUrl'] ?? '',
      userId: map['userId'] ?? '',
      size: map['size'] ?? '',
    );
  }
}
