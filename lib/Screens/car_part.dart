import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Model/models.dart';
import '../Model/order.dart';
import '../Services/Service.dart';
import '../Services/localizations.dart';
import 'car_part_details.dart';
import 'components/car_part_card.dart';
import 'components/pagination.dart';

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
        context: context,
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

  void _addToCart(context, CarPart carPart) async {
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
              "${AppLocalizations.of(context)!.translate('cannot_add_more')!}${carPart.quantity}",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final updatedItem =
      existingItem.copyWith(quantity: existingItem.quantity + 1);
      cartBox.put(existingKey, updatedItem);
    } else {
      if (carPart.quantity > 0) {
        final newItem = CartItem(
            carPart: carPart, quantity: 1, price: carPart.price);
        cartBox.add(newItem);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('out_of_stock')!,
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
        content: Text(
            '${carPart.name} ${AppLocalizations.of(context)!.translate('added_to_cart')!}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.translate('view_cart')!,
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
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('loading')!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.translate('something_wrong')!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadCarParts(refresh: true),
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.translate('retry')!),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                    onAddToCart: () => _addToCart(context,carPart),
                  );
                },
              ),
            ),
          ),
          PaginationControls(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onNext: _loadNextPage,
            onPrevious: _loadPreviousPage,
          )        ],
      ),
    );
  }
}
