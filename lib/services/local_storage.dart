import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsavvy/models/cart_item.dart';
import 'package:shopsavvy/models/product.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Exception('Failed to initialize SharedPreferences: $e');
    }
  }

  // Cart methods
  static List<CartItem> getCartItems() {
    try {
      final cartJson = _prefs.getStringList('cart') ?? [];
      return cartJson.map((item) {
        try {
          return CartItem.fromJson(item);
        } catch (e) {
          // Remove invalid cart items
          return null;
        }
      }).whereType<CartItem>().toList();
    } catch (e) {
      // If corrupted, clear cart and return empty list
      _prefs.remove('cart');
      return [];
    }
  }

  static Future<bool> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cart = getCartItems();
      final existingIndex = cart.indexWhere((item) => item.productId == product.id);
      
      if (existingIndex >= 0) {
        cart[existingIndex].quantity += quantity;
      } else {
        cart.add(CartItem(
          productId: product.id!,
          title: product.title!,
          price: product.price!,
          thumbnail: product.thumbnail!,
          quantity: quantity,
        ));
      }
      
      return await _prefs.setStringList('cart', cart.map((item) => item.toJson()).toList());
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromCart(int productId) async {
    try {
      final cart = getCartItems();
      cart.removeWhere((item) => item.productId == productId);
      return await _prefs.setStringList('cart', cart.map((item) => item.toJson()).toList());
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateCartItemQuantity(int productId, int newQuantity) async {
    try {
      final cart = getCartItems();
      final index = cart.indexWhere((item) => item.productId == productId);
      
      if (index >= 0) {
        if (newQuantity > 0) {
          cart[index].quantity = newQuantity;
        } else {
          cart.removeAt(index);
        }
        return await _prefs.setStringList('cart', cart.map((item) => item.toJson()).toList());
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearCart() async {
    try {
      return await _prefs.remove('cart');
    } catch (e) {
      return false;
    }
  }

  // Wishlist methods
  static List<int> getWishlist() {
    try {
      final wishlistJson = _prefs.getStringList('wishlist') ?? [];
      return wishlistJson.map((id) {
        try {
          return int.parse(id);
        } catch (e) {
          return -1; // Invalid ID
        }
      }).where((id) => id != -1).toList();
    } catch (e) {
      // If corrupted, clear wishlist and return empty list
      _prefs.remove('wishlist');
      return [];
    }
  }

  static Future<bool> toggleWishlist(int productId) async {
    try {
      final wishlist = getWishlist();
      
      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
      } else {
        wishlist.add(productId);
      }
      
      return await _prefs.setStringList(
        'wishlist', 
        wishlist.map((id) => id.toString()).toList()
      );
    } catch (e) {
      return false;
    }
  }

  static bool isInWishlist(int productId) {
    return getWishlist().contains(productId);
  }

  // User methods
  static Future<bool> saveUserCredentials(String email, String password) async {
    try {
      await _prefs.setString('user_email', email);
      await _prefs.setString('user_password', password);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, String?> getUserCredentials() {
    try {
      return {
        'email': _prefs.getString('user_email'),
        'password': _prefs.getString('user_password'),
      };
    } catch (e) {
      return {'email': null, 'password': null};
    }
  }

  static Future<bool> clearUserCredentials() async {
    try {
      await _prefs.remove('user_email');
      await _prefs.remove('user_password');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all data (for logout)
  static Future<bool> clearAll() async {
    try {
      await clearCart();
      await _prefs.remove('wishlist');
      await clearUserCredentials();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final credentials = getUserCredentials();
    return credentials['email'] != null && credentials['password'] != null;
  }
}