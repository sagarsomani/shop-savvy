import 'package:flutter/material.dart';
import 'package:shopsavvy/models/product.dart';
import 'package:shopsavvy/screens/product_detail_screen.dart';
import 'package:shopsavvy/services/api_service.dart';
import 'package:shopsavvy/services/local_storage.dart';
import 'package:shopsavvy/widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  const WishlistScreen({super.key, required this.onUpdate});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistProducts();
  }

  Future<void> _loadWishlistProducts() async {
    setState(() => _isLoading = true);
    final wishlistIds = LocalStorage.getWishlist();
    
    try {
      final allProducts = await ApiService.fetchProducts();
      setState(() {
        _wishlistProducts = allProducts.products!
            .where((product) => wishlistIds.contains(product.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load wishlist: $e')),
      );
    }
  }

  void _toggleWishlist(int productId) {
    LocalStorage.toggleWishlist(productId);
    _loadWishlistProducts();
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Your Wishlist',style: TextStyle(color:Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _wishlistProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color:Theme.of(context).primaryColor,),
                      SizedBox(height: 16),
                      Text(
                        'Your wishlist is empty',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ) ,
                        onPressed: () => Navigator.pop(context),
                        child: Text('Browse Products'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final product = _wishlistProducts[index];
                    return ProductCard(
                      product: product,
                      isInWishlist: true,
                      onWishlistToggle: _toggleWishlist,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: product,
                              onUpdate: () {
                                _loadWishlistProducts();
                                widget.onUpdate();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}