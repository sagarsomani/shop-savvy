import 'package:flutter/material.dart';
import 'package:shopsavvy/models/cart_item.dart';
import 'package:shopsavvy/screens/checkout_screen.dart';
import 'package:shopsavvy/services/local_storage.dart';
import 'package:shopsavvy/widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  const CartScreen({required this.onUpdate, super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _totalPrice = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    setState(() {
      _cartItems = LocalStorage.getCartItems();
      _totalPrice = _cartItems.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      );
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(int productId, int newQuantity) async {
    setState(() => _isLoading = true);
    await LocalStorage.updateCartItemQuantity(productId, newQuantity);
    await _loadCartItems();
    widget.onUpdate();
  }

  Future<void> _removeItem(int productId) async {
    setState(() => _isLoading = true);
    await LocalStorage.removeFromCart(productId);
    await _loadCartItems();
    widget.onUpdate();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from cart')),
    );
  }

  Future<void> _clearCart() async {
    setState(() => _isLoading = true);
    await LocalStorage.clearCart();
    await _loadCartItems();
    widget.onUpdate();
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _cartItems,
          totalPrice: _totalPrice,
          onOrderPlaced: () {
            LocalStorage.clearCart();
            _loadCartItems();
            widget.onUpdate();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined,  color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Cart', style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showClearCartDialog(),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadCartItems,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _cartItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return CartItemCard(
                              item: item,
                              onQuantityChanged: (newQuantity) =>
                                  _updateQuantity(item.productId, newQuantity),
                              onRemove: () => _removeItem(item.productId),
                            );
                          },
                        ),
                      ),
                    ),
                    _buildCheckoutFooter(theme),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Continue Shopping', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text('Proceed to Checkout', style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearCartDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text('Are you sure you want to remove all items from your cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}