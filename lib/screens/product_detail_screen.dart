// FILE: lib/screens/product_detail_screen.dart
// Update the Order Now button to go directly to checkout

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/review_provider.dart';
import '../providers/order_provider.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_stars.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedSize = 'M';
  final _reviewController = TextEditingController();
  int _selectedRating = 5;
  late Product _product;
  bool _isLoading = true;

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final product = route.settings.arguments as Product;
        _product = product;
        _isLoading = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<ReviewProvider>().listenToProductReviews(_product.id);
          }
        });
      } else {
        _isLoading = false;
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Product not found')));
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      _isLoading = false;
      print('Error loading product: $e');
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1E20),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  Image.network(
                    _product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Color(0xFF8F959E),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingStars(rating: _product.rating),
                      const SizedBox(width: 8),
                      Text(
                        '(${_product.reviewCount} reviews)',
                        style: const TextStyle(color: Color(0xFF8F959E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₱${_product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9775FA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Size Selection
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D1E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableSizes.length,
                      itemBuilder: (context, index) {
                        final size = _availableSizes[index];
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSize = size;
                            });
                          },
                          child: Container(
                            width: 55,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF9775FA)
                                      : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isSelected
                                      ? null
                                      : Border.all(color: Colors.grey[200]!),
                            ),
                            child: Center(
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF1D1E20),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity selector
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                              constraints: const BoxConstraints(minWidth: 40),
                            ),
                            SizedBox(
                              width: 50,
                              child: Center(
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              constraints: const BoxConstraints(minWidth: 40),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Add to Cart and Order Now buttons
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<CartProvider>(
                          builder: (context, cart, _) {
                            return CustomButton(
                              text: 'Add to Cart',
                              isLoading: cart.isLoading,
                              onPressed: () async {
                                await cart.addItem(
                                  _product,
                                  quantity: _quantity,
                                  size: _selectedSize,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added $_quantity item(s) to cart (Size: $_selectedSize)',
                                      ),
                                      action: SnackBarAction(
                                        label: 'View Cart',
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/cart');
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Go directly to checkout with this product
                            _goToCheckout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9775FA),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Order Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Reviews section
                  const Text(
                    'Customer Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildWriteReviewSection(_product.id),
                  const SizedBox(height: 16),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      if (reviewProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final reviews = reviewProvider.getReviewsForProduct(
                        _product.id,
                      );
                      if (reviews.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.rate_review,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No reviews yet. Be the first to review!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFF9775FA,
                                        ),
                                        child: Text(
                                          review.userName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            RatingStars(
                                              rating: review.rating.toDouble(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${review.date.day}/${review.date.month}/${review.date.year}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    review.comment,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This method goes directly to checkout WITHOUT adding to cart
  Future<void> _goToCheckout(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to place order'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (auth.currentUser!.address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add your address in profile first'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, '/address');
      return;
    }

    // Show checkout dialog or navigate to payment screen
    _showCheckoutDialog(context);
  }

  void _showCheckoutDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final total = _product.price * _quantity;

    final addressController = TextEditingController(
      text: auth.currentUser?.address ?? '',
    );
    final cityController = TextEditingController(
      text: auth.currentUser?.city ?? '',
    );
    final zipController = TextEditingController(
      text: auth.currentUser?.zipCode ?? '',
    );
    String selectedPaymentMethod = 'Cash on Delivery';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Size: $_selectedSize | Qty: $_quantity',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8F959E),
                                ),
                              ),
                              Text(
                                '₱${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9775FA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery Address
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: 'Street Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            hintText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: zipController,
                          decoration: InputDecoration(
                            hintText: 'ZIP Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    'Cash on Delivery',
                    Icons.money_off_csred,
                    'Pay when you receive the order',
                    selectedPaymentMethod,
                    (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  ),
                  _buildPaymentOption(
                    'Credit Card',
                    Icons.credit_card,
                    'Pay with credit or debit card',
                    selectedPaymentMethod,
                    (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  ),
                  _buildPaymentOption(
                    'GCash',
                    Icons.qr_code_scanner,
                    'Pay via GCash',
                    selectedPaymentMethod,
                    (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Place Order Button
                  Consumer<OrderProvider>(
                    builder: (context, orderProvider, _) {
                      return CustomButton(
                        text: 'Place Order',
                        isLoading: orderProvider.isLoading,
                        onPressed: () async {
                          if (addressController.text.isEmpty ||
                              cityController.text.isEmpty ||
                              zipController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter complete address'),
                              ),
                            );
                            return;
                          }

                          final items = [
                            CartItem(
                              id:
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                              productId: _product.id,
                              title: '${_product.title} (Size: $_selectedSize)',
                              price: _product.price,
                              quantity: _quantity,
                              imageUrl: _product.imageUrl,
                              userId: auth.currentUser!.id,
                              size: _selectedSize,
                            ),
                          ];

                          await orderProvider.addOrder(
                            items: items,
                            total: total,
                            address: addressController.text,
                            city: cityController.text,
                            zipCode: zipController.text,
                            paymentMethod: selectedPaymentMethod,
                            userId: auth.currentUser!.id,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              '/order-confirmation',
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(
    String method,
    IconData icon,
    String description,
    String selectedMethod,
    Function(String) onChanged,
  ) {
    final isSelected = selectedMethod == method;
    return GestureDetector(
      onTap: () => onChanged(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF9775FA).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF9775FA) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: method,
              groupValue: selectedMethod,
              onChanged: (value) => onChanged(value!),
              activeColor: const Color(0xFF9775FA),
            ),
            Icon(icon, color: const Color(0xFF9775FA)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8F959E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteReviewSection(String productId) {
    final auth = context.read<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please login to write a review',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Share your experience with this product...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Consumer<ReviewProvider>(
                builder: (context, reviewProvider, _) {
                  return ElevatedButton(
                    onPressed:
                        reviewProvider.isLoading
                            ? null
                            : () async {
                              if (_reviewController.text.isNotEmpty) {
                                await reviewProvider.addReview(
                                  productId,
                                  auth.currentUser!.id,
                                  auth.currentUser!.name,
                                  _selectedRating,
                                  _reviewController.text,
                                );
                                _reviewController.clear();
                                setState(() {
                                  _selectedRating = 5;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Review submitted!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please write a review'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9775FA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        reviewProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Submit Review',
                              style: TextStyle(fontSize: 16),
                            ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
