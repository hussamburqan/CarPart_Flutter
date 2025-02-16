import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Model/models.dart';
import '../Model/order.dart';
import '../Services/Service.dart';
import 'car_part_details.dart';
import 'components/car_part_card.dart';

class CarPartsPage extends StatefulWidget {
  final Category? category;
  final Seller? seller;

  const CarPartsPage({Key? key, this.category, this.seller}) : super(key: key);

  @override
  _CarPartsPageState createState() => _CarPartsPageState();
}

class _CarPartsPageState extends State<CarPartsPage> {
  final _apiService = ApiService();
  List<CarPart> _carParts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 6;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCarParts(refresh: true);
  }

  Future<void> _loadCarParts({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
        if (refresh) {
          _carParts.clear();
          _currentPage = 1;
          _hasMore = true;
        }
      });
      print(widget.seller?.id);
      int? id;
      if(widget.seller?.id != null){
         id = widget.seller!.id!-1;
      }
      final response = await _apiService.getCarParts(
        query: '',
        minPrice: null,
        maxPrice: null,
        condition: null,
        sortBy: '-created_at',
        page: _currentPage,
        categoryId: widget.category?.id,
        sellerId: widget.seller?.id,
        perPage: _itemsPerPage,
      );
      print(response);
      setState(() {
        _carParts = (response['results'] as List)
            .map((json) => CarPart.fromJson(json))
            .toList();

        _totalPages = int.tryParse(response['total_pages'].toString()) ?? 1;
        _hasMore = _currentPage < _totalPages;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadNextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        _loadCarParts();
      });
    }
  }

  void _loadPreviousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        _loadCarParts();
      });
    }
  }

  void _addToCart(CarPart carPart) async {
    final cartBox = Hive.box<CartItem>('cartBox');

    final existingKey = cartBox.keys.firstWhere(
          (key) => cartBox.get(key)!.carPart.id == carPart.id,
      orElse: () => null,
    );

    if (existingKey != null) {
      final existingItem = cartBox.get(existingKey)!;

      if (existingItem.quantity >= carPart.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot add more. Only ${carPart.quantity} in stock!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
      cartBox.put(existingKey, updatedItem);
    } else {
      if (carPart.quantity > 0) {
        final newItem = CartItem(carPart: carPart, quantity: 1, price: carPart.price);
        cartBox.add(newItem);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Item is out of stock!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${carPart.name} added to cart!'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category?.name ?? widget.seller?.username ?? 'Car Parts',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => _loadCarParts(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadCarParts(refresh: true),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _carParts.length,
                itemBuilder: (context, index) {
                  final carPart = _carParts[index];
                  return CarPartCard(
                    carPart: carPart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarPartDetailsPage(carPart: carPart),
                        ),
                      );
                    },
                    onAddToCart: () => _addToCart(carPart),
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

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage > 1 ? _loadPreviousPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage > 1 ? Colors.blue : Colors.grey[300],
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
          SizedBox(width: 12),
          Text(
            'Page $_currentPage of $_totalPages',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage < _totalPages ? _loadNextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage < _totalPages ? Colors.blue : Colors.grey[300],
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
        ],
      ),
    );
  }
}
