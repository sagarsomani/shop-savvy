class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'https://dummyjson.com';
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  static const String searchEndpoint = '/products/search';

  // Local Storage Keys
  static const String cartKey = 'cart';
  static const String wishlistKey = 'wishlist';
  static const String userEmailKey = 'user_email';
  static const String userPasswordKey = 'user_password';

  // App Constants
  static const String appName = 'ShopSavvy';
  static const String currencySymbol = '\$';  // Added this line
  
  // Default Values
  static const double defaultProductRating = 0.0;
  static const double defaultProductPrice = 0.0;
  static const int defaultProductQuantity = 1;

  // Sort Options
  static const List<String> sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Popularity',
  ];

  // Categories
  static const List<String> categories = [
    'smartphones',
    'laptops',
    'fragrances',
    'skincare',
    'groceries',
    'home-decoration',
    'furniture',
    'tops',
    'womens-dresses',
    'womens-shoes',
    'mens-shirts',
    'mens-shoes',
    'mens-watches',
    'womens-watches',
    'womens-bags',
    'womens-jewellery',
    'sunglasses',
    'automotive',
    'motorcycle',
    'lighting',
  ];
}