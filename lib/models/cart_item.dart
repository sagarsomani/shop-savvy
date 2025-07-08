import 'dart:convert';

class CartItem {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.quantity = 1,
  });

  factory CartItem.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return CartItem(
      productId: json['productId'],
      title: json['title'],
      price: json['price'].toDouble(),
      thumbnail: json['thumbnail'],
      quantity: json['quantity'],
    );
  }

  String toJson() {
    return jsonEncode({
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'quantity': quantity,
    });
  }

  double get totalPrice => price * quantity;
}