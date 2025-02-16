import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Model/order.dart';
import '../Services/orderservies.dart';
import 'Order_Details_Page.dart';

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
      _showErrorDialog('Your cart is empty.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final order = await _orderService.createOrder(_cartItems);

      final cartBox = Hive.box<CartItem>('cartBox');
      await cartBox.clear();

      setState(() => _cartItems = []);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
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


  void _deleteCartItem(int index) async {
    final cartBox = Hive.box<CartItem>('cartBox');
    final key = cartBox.keyAt(index);
    await cartBox.delete(key);

    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  void _showErrorDialog(dynamic error) {
    String errorMessage = 'Failed to place the order. Please try again later.';

    if (error is DioException) {
      if (error.response != null && error.response!.data is Map<String, dynamic>) {
        errorMessage = error.response!.data['error'] ?? errorMessage;
      } else {
        errorMessage = 'An unexpected error occurred. Please check your connection.';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Order Failed',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(errorMessage, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
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
          'Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? const Center(
        child: Text('Your cart is empty'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: item.carPart.photo?.isNotEmpty ?? false
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
              title: Text(item.carPart.name),
              subtitle: Text(
                'Quantity: ${item.quantity}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCartItem(index),
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
                      'Total:',
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
                    _isLoading ? 'Processing...' : 'Place Order',
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
