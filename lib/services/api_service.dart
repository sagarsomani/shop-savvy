import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopsavvy/models/product.dart';
import 'package:shopsavvy/utils/constants.dart';

class ApiService {
  static Future<ProductList> fetchProducts({String? category, String? query}) async {
    String url = '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}';
    
    if (category != null) {
      url += '/category/$category';
    } else if (query != null) {
      url += '/search?q=$query';
    }
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return ProductList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<String>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}'),
    );
    
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load categories');
    }
  }
}

  Future<List<String>> fetchCategories() async {
  final response = await http.get(
    Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}'),
  );
  
  if (response.statusCode == 200) {
    // Parse as List<dynamic> first, then cast to List<String>
    final List<dynamic> categoriesJson = json.decode(response.body);
    return categoriesJson.cast<String>();
  } else {
    throw Exception('Failed to load categories');
  }
}