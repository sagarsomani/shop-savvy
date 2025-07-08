import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopsavvy/utils/constants.dart';

class AppHelpers {
  // Format currency
  static String formatPrice(double price) {
    return NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    ).format(price);
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Parse category name
  static String parseCategoryName(String category) {
    return category.replaceAll('-', ' ').split(' ').map(capitalize).join(' ');
  }

  // Calculate discount price
  static double calculateDiscountPrice(double price, double discountPercentage) {
    return price - (price * discountPercentage / 100);
  }
}