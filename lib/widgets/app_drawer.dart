import 'package:flutter/material.dart';
import 'package:shopsavvy/screens/auth/sign_in_screen.dart';
import 'package:shopsavvy/screens/cart_screen.dart';
import 'package:shopsavvy/screens/home_screen.dart';
import 'package:shopsavvy/screens/wishlist_screen.dart';
import 'package:shopsavvy/services/local_storage.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'ShopSavvy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your shopping companion',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('My Orders'),
            onTap: () {
              // Navigate to orders screen
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CartScreen(onUpdate: () {  },),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite,),
            title: Text('Wishlist'),
            onTap: () {
              // Navigate to wishlist screen
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => WishlistScreen(onUpdate: () {  },),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings screen
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              LocalStorage.clearAll();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}