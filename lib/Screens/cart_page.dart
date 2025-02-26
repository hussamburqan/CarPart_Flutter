import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Model/order.dart';
import '../Services/order_servies.dart';
import 'Order_Details_Page.dart';
import '../Services/localizations.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  List<CartItem> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final cartBox = Hive.box<CartItem>('cartBox');
    setState(() {
      _cartItems = cartBox.values.toList();
    });
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _createOrder() async {
    if (_cartItems.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)!.translate('cart_empty')!);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = await _orderService.createOrder(
        context: context,
        cartItems: _cartItems,
      );

      final cartBox = Hive.box<CartItem>('cartBox');
      await cartBox.clear();

      setState(() => _cartItems = []);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('order_created_success')!),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsPage(order: order),
        ),
      );
    } catch (e) {
      _showErrorDialog(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateQuantity(int index, int newQuantity) async {
    final cartBox = Hive.box<CartItem>('cartBox');
    final item = _cartItems[index];

    if (newQuantity <= 0) {
      _deleteCartItem(index);
      return;
    }

    if (newQuantity > item.carPart.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.translate('only')} ${item.carPart.quantity} ${AppLocalizations.of(context)!.translate('items_in_stock')}!',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final key = cartBox.keyAt(index);
    final updatedItem = item.copyWith(quantity: newQuantity);
    await cartBox.put(key, updatedItem);

    setState(() {
      _cartItems[index] = updatedItem;
    });
  }

  void _deleteCartItem(int index) async {
    final cartBox = Hive.box<CartItem>('cartBox');
    final key = cartBox.keyAt(index);
    await cartBox.delete(key);

    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate('item_removed')!),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorDialog(dynamic error) {
    String errorMessage = AppLocalizations.of(context)!.translate('order_failed')!;

    if (error is DioException) {
      if (error.response != null && error.response!.data is Map<String, dynamic>) {
        errorMessage = error.response!.data['error'] ?? errorMessage;
      } else {
        errorMessage = AppLocalizations.of(context)!.translate('unexpected_error')!;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.translate('order_failed')!,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.translate('ok')!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('cart')!,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? Center(
        child: Text(AppLocalizations.of(context)!.translate('cart_empty')!),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Image section
                  item.carPart.photo?.isNotEmpty ?? false
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://carparts1234.pythonanywhere.com${item.carPart.photo!}',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_not_supported),
                  ),
                  const SizedBox(width: 12),

                  // Title and price section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.carPart.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Decrease button
                            IconButton(
                              icon: const Icon(Icons.remove),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () => _updateQuantity(index, item.quantity - 1),
                            ),
                            // Quantity display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Increase button
                            IconButton(
                              icon: const Icon(Icons.add),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () => _updateQuantity(index, item.quantity + 1),
                            ),
                          ],
                        ),
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCartItem(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_cartItems.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('total')!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cartItems.isEmpty ? null : _createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isLoading
                        ? AppLocalizations.of(context)!.translate('processing')!
                        : AppLocalizations.of(context)!.translate('place_order')!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}