import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Model/order.dart';
import '../Services/orderservies.dart';
import 'Order_Details_Page.dart';

class OrdersPage extends StatefulWidget {
  final bool isSeller;

  const OrdersPage({Key? key, required this.isSeller}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  bool _isLoading = false;

  int _currentPage = 1;
  int _totalPages = 1;
  final int _perPage = 5;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({int page = 1}) async {
    setState(() => _isLoading = true);
    try {
      final response = widget.isSeller
          ? await _orderService.getSoldOrders(page: page, perPage: _perPage)
          : await _orderService.getOrders(page: page, perPage: _perPage);


      setState(() {
        _orders = response['orders'] ?? [];
        _currentPage = page;
        _totalPages = response['total_pages'] ?? 1;
      });

    } catch (e) {
      _showErrorSnackBar('Failed to load orders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        title: Text(
          widget.isSeller ? 'Sold Orders' : 'My Orders',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : _orders.isEmpty
          ? _buildEmptyOrders()
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadOrders(page: 1),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  return OrderCard(
                    order: _orders[index],
                    onTap: () => _navigateToOrderDetails(_orders[index]),
                  );
                },
              ),
            ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            widget.isSeller ? 'No sold orders yet' : 'No orders yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _currentPage > 1 ? () =>
                    _loadOrders(page: _currentPage - 1) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPage > 1 ? Colors.blue : Colors
                      .grey[300],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Previous', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Page $_currentPage of $_totalPages',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _currentPage < _totalPages ? () =>
                    _loadOrders(page: _currentPage + 1) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPage < _totalPages
                      ? Colors.blue
                      : Colors.grey[300],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Next', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onTap, // Added long press gesture
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildItemsSummary(order.items),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} items',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}  Widget _buildItemsSummary(List<OrderItem> items) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length && i < 2; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 8 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  items[i].carPartName,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'x${items[i].quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        if (items.length > 2)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '+ ${items.length - 2} more items',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    ),
  );
}
