import 'package:flutter/material.dart';
import 'package:my_shop/screens/order_screen.dart';
import 'package:my_shop/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome There!'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            const Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(
                Icons.shopping_bag_rounded,
              ),
              title: Text(
                'Shop',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.credit_card,
              ),
              title: Text(
                'My Orders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(OrderScreen.routeName);
              },
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: Text(
                'Manage Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  ManageUserProducts.routeName,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
