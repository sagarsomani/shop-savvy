import 'package:flutter/material.dart';
import 'package:shopsavvy/models/product.dart';
import 'package:shopsavvy/screens/filter_screen.dart';
import 'package:shopsavvy/screens/product_detail_screen.dart';
import 'package:shopsavvy/services/api_service.dart';
import 'package:shopsavvy/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  ProductListScreen({required this.onUpdate});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<ProductList> _productsFuture;
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiService.fetchProducts();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() => _categories = categories);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.fetchProducts(
        category: _selectedCategory,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _productsFuture = Future.value(products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh products: $e')),
      );
    }
  }

  void _applyFilters(Map<String, dynamic> filters) async {
    setState(() {
      _selectedCategory = filters['category'];
      _searchQuery = filters['searchQuery'] ?? '';
      _isLoading = true;
    });

    try {
      final products = await ApiService.fetchProducts(
        category: _selectedCategory,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _productsFuture = Future.value(products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply filters: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _refreshProducts();
              },
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                    _refreshProducts();
                  },
                ),
                ..._categories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                    _refreshProducts();
                  },
                )),
                IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () async {
                    final filters = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterScreen(
                          currentCategory: _selectedCategory,
                          currentQuery: _searchQuery,
                        ),
                      ),
                    );
                    if (filters != null) {
                      _applyFilters(filters);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: FutureBuilder<ProductList>(
                      future: _productsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.products!.isEmpty) {
                          return Center(child: Text('No products found'));
                        }

                        return GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: snapshot.data!.products!.length,
                          itemBuilder: (context, index) {
                            final product = snapshot.data!.products![index];
                            return ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: product,
                                      onUpdate: widget.onUpdate,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}