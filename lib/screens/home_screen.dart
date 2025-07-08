import 'package:flutter/material.dart';
import 'package:shopsavvy/screens/cart_screen.dart';
import 'package:shopsavvy/screens/product_list_screen.dart';
import 'package:shopsavvy/screens/wishlist_screen.dart';
import 'package:shopsavvy/services/local_storage.dart';
import 'package:shopsavvy/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _cartItemCount = 0;
  int _wishlistItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  void _loadCounts() {
    setState(() {
      _cartItemCount = LocalStorage.getCartItems().length;
      _wishlistItemCount = LocalStorage.getWishlist().length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductListScreen(onUpdate: _loadCounts),
      WishlistScreen(onUpdate: _loadCounts),
      CartScreen(onUpdate: _loadCounts),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
       iconTheme: const IconThemeData(color: Colors.white),
        title: Text('ShopSavvy', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.favorite, color: Colors.white),
                if (_wishlistItemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_wishlistItemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistScreen(onUpdate: _loadCounts)),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart,color: Colors.white,),
                if (_cartItemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_cartItemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen(onUpdate: _loadCounts)),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}