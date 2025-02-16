import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../Model/models.dart';
import '../Services/Service.dart';

class EditCarPartPage extends StatefulWidget {
  final CarPart carPart;

  const EditCarPartPage({Key? key, required this.carPart}) : super(key: key);

  @override
  _EditCarPartPageState createState() => _EditCarPartPageState();
}

class _EditCarPartPageState extends State<EditCarPartPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  int? _selectedCategoryId;
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  final TextEditingController _categorySearchController = TextEditingController();
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.carPart.name);
    _descriptionController = TextEditingController(text: widget.carPart.description);
    _priceController = TextEditingController(text: widget.carPart.price.toString());
    _quantityController = TextEditingController(text: widget.carPart.quantity.toString());
    _selectedCategoryId = widget.carPart.categoryId;
    _currentImageUrl = widget.carPart.photo;
    _loadCategories();
    _categorySearchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
    } catch (e) {
      _showSnackBar('Failed to load categories: $e');
    }
  }

  void _filterCategories() {
    final query = _categorySearchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _categories.where((category) {
        return category.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _currentImageUrl = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      _showSnackBar('Please fill all fields and select a category');
      return;
    }

    setState(() => _isLoading = true);

    final formData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'stock': _quantityController.text,
      'category': _selectedCategoryId.toString(),
    };

    try {
      if (_selectedImage != null) {
        await _apiService.updateCarPart(widget.carPart.id, formData, _selectedImage!.path);
      } else if (_currentImageUrl != null) {
        await _apiService.updateCarPartNoPhoto(widget.carPart.id, formData);
      } else {
        throw Exception('Please select an image');
      }
      _showSnackBar('Product updated successfully!', isError: false);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to update product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Car Part'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_nameController, 'Product Name', Icons.shopping_bag),
                _buildTextField(_descriptionController, 'Description', Icons.description),
                _buildTextField(_priceController, 'Price', Icons.attach_money, isNumber: true),
                _buildTextField(_quantityController, 'Stock', Icons.inventory, isNumber: true),
                const SizedBox(height: 20),
                _buildCategorySearch(),
                const SizedBox(height: 20),
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildCategorySearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categorySearchController,
          decoration: InputDecoration(
            labelText: 'Search Category',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          items: _filteredCategories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
          decoration: InputDecoration(
            labelText: 'Select Category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: (value) => value == null ? 'Please select a category' : null,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : _currentImageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network('https://carparts1234.pythonanywhere.com$_currentImageUrl', fit: BoxFit.cover),
              )
                  : Icon(Icons.add_a_photo, size: 50, color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Update Product'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}