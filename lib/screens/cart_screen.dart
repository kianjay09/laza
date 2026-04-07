// FILE: lib/screens/cart_screen.dart
// DESCRIPTION: Shopping cart with checkout and PHP currency

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart'), elevation: 0),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return CartItemWidget(
                      item: cart.items[index],
                      onQuantityChanged: (newQuantity) {
                        cart.updateQuantity(cart.items[index].id, newQuantity);
                      },
                      onRemove: () {
                        cart.removeItem(cart.items[index].id);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Proceed to Checkout',
                      onPressed: () {
                        _showCheckoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final addressController = TextEditingController(
      text: auth.currentUser?.address ?? '',
    );
    final cityController = TextEditingController(
      text: auth.currentUser?.city ?? '',
    );
    final zipController = TextEditingController(
      text: auth.currentUser?.zipCode ?? '',
    );
    final paymentMethod = ValueNotifier<String>('Credit Card');

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
                  const Text('Delivery Address'),
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
                  const Text('Payment Method'),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: paymentMethod,
                    builder: (context, value, _) {
                      return Column(
                        children: [
                          RadioListTile(
                            title: const Text('Credit Card'),
                            value: 'Credit Card',
                            groupValue: value,
                            onChanged: (v) => paymentMethod.value = v!,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            title: const Text('PayPal'),
                            value: 'PayPal',
                            groupValue: value,
                            onChanged: (v) => paymentMethod.value = v!,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile(
                            title: const Text('Cash on Delivery'),
                            value: 'Cash on Delivery',
                            groupValue: value,
                            onChanged: (v) => paymentMethod.value = v!,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
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

                          final cart = context.read<CartProvider>();
                          final orderProvider = context.read<OrderProvider>();

                          await orderProvider.addOrder(
                            items: List.from(cart.items),
                            total: cart.totalAmount,
                            address: addressController.text,
                            city: cityController.text,
                            zipCode: zipController.text,
                            paymentMethod: paymentMethod.value,
                            userId: auth.currentUser?.id ?? '',
                          );

                          await cart.clearCart();

                          if (context.mounted) {
                            Navigator.pop(context);
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
}
