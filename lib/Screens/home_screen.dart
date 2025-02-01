import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final ApiService _apiService = ApiService();
  // final AuthService _authService = AuthService();
  // List<CarPart> _carParts = [];
  // List<CarPart> _filteredCarParts = [];
  // bool _isLoading = true;
  // String? _error;
  // Map<int, int> _cartItems = {};
  // TextEditingController _searchController = TextEditingController();
  // bool _isAdmin = false;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _loadData();
  // }
  //
  //
  // Future<void> _loadData() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _error = null;
  //     });
  //
  //     final carParts = await _apiService.getCarParts();
  //     if (mounted) {
  //       setState(() {
  //         _carParts = carParts;
  //         _filteredCarParts = carParts;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _error = e.toString();
  //         _isLoading = false;
  //       });
  //
  //       if (e.toString().contains('Session expired')) {
  //         Navigator.of(context).pushReplacementNamed('/login');
  //       }
  //     }
  //   }
  // }
  //
  // void _filterCarParts(String query) {
  //   setState(() {
  //     _filteredCarParts = _carParts.where((part) {
  //       final nameMatch = part.name.toLowerCase().contains(query.toLowerCase());
  //       final descMatch = part.description.toLowerCase().contains(query.toLowerCase());
  //       return nameMatch || descMatch;
  //     }).toList();
  //   });
  // }
  //
  // void _addToCart(CarPart carPart) {
  //   setState(() {
  //     _cartItems.update(
  //       carPart.id,
  //           (value) => value + 1,
  //       ifAbsent: () => 1,
  //     );
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('${carPart.name} added to cart'),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }
  //
  // Future<void> _handleLogout() async {
  //   try {
  //     await _authService.logout();
  //     Navigator.of(context).pushReplacementNamed('/login');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Logout failed: ${e.toString()}')),
  //     );
  //   }
  // }
  //
  // Future<void> _deleteCarPart(int id) async {
  //   try {
  //     await _apiService.deleteCarPart(id);
  //     await _loadData();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Delete failed: ${e.toString()}')),
  //     );
  //   }
  // }
  //
  // Future<void> _confirmDelete(CarPart carPart) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Delete Car Part'),
  //       content: Text('Are you sure you want to delete ${carPart.name}?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _deleteCarPart(carPart.id);
  //           },
  //           child: Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Future<void> _navigateToEditScreen(CarPart carPart) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditCarPartScreen(carPart: carPart),
  //     ),
  //   );
  //
  //   if (result == true) {
  //     await _loadData();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
     return Placeholder();
       // Scaffold(
    //   appBar: AppBar(
    //     title: Text('Car Parts Shop'),
    //     actions: [
    //       IconButton(
    //         icon: Icon(Icons.search),
    //         onPressed: () => showSearch(
    //           context: context,
    //           delegate: CarPartSearch(_carParts),
    //         ),
    //       ),
    //       IconButton(
    //         icon: Stack(
    //           children: [
    //             Icon(Icons.shopping_cart),
    //             if (_cartItems.isNotEmpty)
    //               Positioned(
    //                 right: 0,
    //                 top: 0,
    //                 child: Container(
    //                   padding: EdgeInsets.all(2),
    //                   decoration: BoxDecoration(
    //                     color: Colors.red,
    //                     borderRadius: BorderRadius.circular(10),
    //                   ),
    //                   constraints: BoxConstraints(
    //                     minWidth: 16,
    //                     minHeight: 16,
    //                   ),
    //                   child: Text(
    //                     _cartItems.values.reduce((a, b) => a + b).toString(),
    //                     style: TextStyle(
    //                       color: Colors.white,
    //                       fontSize: 10,
    //                     ),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                 ),
    //               ),
    //           ],
    //         ),
    //         onPressed: () {
    //           // Navigate to cart screen
    //         },
    //       ),
    //       IconButton(
    //         icon: Icon(Icons.logout),
    //         onPressed: _handleLogout,
    //       ),
    //     ],
    //   ),
    //   floatingActionButton: _isAdmin
    //       ? FloatingActionButton(
    //     onPressed: () => _navigateToEditScreen(CarPart.empty()),
    //     child: Icon(Icons.add),
    //     tooltip: 'Add New Part',
    //   )
    //       : null,
    //   body: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: TextField(
    //           controller: _searchController,
    //           decoration: InputDecoration(
    //             hintText: 'Search car parts...',
    //             prefixIcon: Icon(Icons.search),
    //             border: OutlineInputBorder(),
    //             suffixIcon: IconButton(
    //               icon: Icon(Icons.clear),
    //               onPressed: () {
    //                 _searchController.clear();
    //                 _filterCarParts('');
    //               },
    //             ),
    //           ),
    //           onChanged: _filterCarParts,
    //         ),
    //       ),
    //       Expanded(
    //         child: RefreshIndicator(
    //           onRefresh: _loadData,
    //           child: _buildContent(),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
//
//   Widget _buildContent() {
//     if (_isLoading) return Center(child: CircularProgressIndicator());
//     if (_error != null) return _buildErrorWidget();
//     return _buildCarPartsGrid();
//   }
//
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(_error!),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _loadData,
//             child: Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCarPartsGrid() {
//     return GridView.builder(
//       padding: EdgeInsets.all(16),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.75,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: _filteredCarParts.length,
//       itemBuilder: (context, index) {
//         final carPart = _filteredCarParts[index];
//         return Card(
//           elevation: 4,
//           child: Stack(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Stack(
//                       children: [
//                         Image.network(
//                           carPart.photo,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Center(child: Icon(Icons.broken_image)),
//                         ),
//                         if (carPart.stock == 0)
//                           Container(
//                             color: Colors.black54,
//                             child: Center(
//                               child: Text(
//                                 'Out of Stock',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           carPart.name,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           '\$${carPart.price.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 14,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Stock: ${carPart.stock}',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 12,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: carPart.stock > 0
//                               ? () => _addToCart(carPart)
//                               : null,
//                           child: Text(
//                             carPart.stock > 0 ? 'Add to Cart' : 'Out of Stock',
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(double.infinity, 36),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               if (_isAdmin) ...[
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: IconButton(
//                     icon: Icon(Icons.edit, color: Colors.blue),
//                     onPressed: () => _navigateToEditScreen(carPart),
//                   ),
//                 ),
//                 Positioned(
//                   top: 4,
//                   left: 4,
//                   child: IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => _confirmDelete(carPart),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class CarPartSearch extends SearchDelegate<CarPart> {
//   final List<CarPart> carParts;
//
//   CarPartSearch(this.carParts);
//
//   @override
//   List<Widget> buildActions(BuildContext context) => [
//     IconButton(
//       icon: Icon(Icons.clear),
//       onPressed: () => query = '',
//     )
//   ];
//
//   @override
//   Widget buildLeading(BuildContext context) => IconButton(
//     icon: Icon(Icons.arrow_back),
//     onPressed: () => close(context, CarPart.empty()),
//   );
//
//   @override
//   Widget buildResults(BuildContext context) => _buildResults();
//
//   @override
//   Widget buildSuggestions(BuildContext context) => _buildResults();
//
//   Widget _buildResults() {
//     final results = query.isEmpty
//         ? carParts
//         : carParts.where((part) {
//       final nameMatch = part.name.toLowerCase().contains(query.toLowerCase());
//       final descMatch = part.description.toLowerCase().contains(query.toLowerCase());
//       return nameMatch || descMatch;
//     }).toList();
//
//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final part = results[index];
//         return ListTile(
//           leading: Image.network(part.photo, width: 50, height: 50),
//           title: Text(part.name),
//           subtitle: Text('\$${part.price.toStringAsFixed(2)}'),
//           trailing: Text('Stock: ${part.stock}'),
//           onTap: () => close(context, part),
//         );
//       },
//     );
//   }
}