import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Model/models.dart';
import '../Services/Service.dart';
import 'components/my_car_part_card.dart';
import 'components/pagination.dart';
import 'edit_my_part.dart';
import '../../Services/localizations.dart';

class MyCarPartsPage extends StatefulWidget {
  const MyCarPartsPage({Key? key}) : super(key: key);

  @override
  _MyCarPartsPageState createState() => _MyCarPartsPageState();
}

class _MyCarPartsPageState extends State<MyCarPartsPage> {
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

      Box _auth = await Hive.openBox('auth');
      final response = await _apiService.getCarParts(
        query: '',
        minPrice: null,
        maxPrice: null,
        condition: null,
        sortBy: '-created_at',
        page: _currentPage,
        sellerId: _auth.get('id'),
        perPage: _itemsPerPage,
        context: context,
      );

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
        _error = AppLocalizations.of(context)!.translate('load_failed')!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('my_car_parts')!,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add_car_part').then((_) => _loadCarParts(refresh: true));
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
              child: Text(AppLocalizations.of(context)!.translate('retry')!),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadCarParts(refresh: true),
              child: _isLoading && _carParts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
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
                  return GestureDetector(
                    child: CarPartCard(
                      carPart: carPart,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCarPartPage(carPart: carPart),
                          ),
                        ).then((_) => _loadCarParts(refresh: true));
                      },
                    ),
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
          )
        ],
      ),
    );
  }
}