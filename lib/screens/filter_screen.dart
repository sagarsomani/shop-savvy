import 'package:flutter/material.dart';
import 'package:shopsavvy/utils/constants.dart';

class FilterScreen extends StatefulWidget {
  final String? currentCategory;
  final String? currentQuery;

  const FilterScreen({super.key, 
    this.currentCategory,
    this.currentQuery,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String? _selectedCategory;
  late String _searchQuery;
  late String _selectedSort;
  double _minPrice = 0;
  double _maxPrice = 1000;
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
    _searchQuery = widget.currentQuery ?? '';
    _selectedSort = AppConstants.sortOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Filter Products', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'category': _selectedCategory,
                'searchQuery': _searchQuery,
                'sort': _selectedSort,
                'minPrice': _minPrice,
                'maxPrice': _maxPrice,
                'minRating': _minRating,
              });
            },
            child: Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _searchQuery = value,
              controller: TextEditingController(text: _searchQuery),
            ),
            SizedBox(height: 24),
            Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = null);
                  },
                ),
                ...AppConstants.categories.map((category) => FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                )),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Price Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                '\$${_minPrice.toStringAsFixed(0)}',
                '\$${_maxPrice.toStringAsFixed(0)}',
              ),
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            SizedBox(height: 24),
            Text(
              'Minimum Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _minRating.toStringAsFixed(1),
              onChanged: (value) {
                setState(() => _minRating = value);
              },
            ),
            SizedBox(height: 24),
            Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedSort,
              isExpanded: true,
              items: AppConstants.sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedSort = newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }
}