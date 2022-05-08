import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_shop/providers/cart_provider.dart';
import 'package:my_shop/providers/order_provider.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_products.dart';
import 'package:my_shop/screens/order_screen.dart';
import 'package:my_shop/screens/product_details_screen.dart';
import 'package:my_shop/screens/products_screen.dart';
import 'package:my_shop/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProvider(create: (ctx) => OrdersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glitter',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: const Color.fromRGBO(255, 248, 248, 1),
            centerTitle: true,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
            iconTheme: IconThemeData(
              color: Colors.blueGrey.shade900,
            ),
          ),
          primaryColor: Colors.black,
          accentColor: Colors.pink.shade400,
          canvasColor: const Color.fromRGBO(255, 248, 248, 1),
          textTheme: TextTheme(
            titleLarge: TextStyle(
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const ProductsScreen(),
        routes: {
          ProductDetailsScreen.routeName: (ctx) => const ProductDetailsScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
          OrderScreen.routeName: (ctx) => const OrderScreen(),
          ManageUserProducts.routeName: (ctx) => const ManageUserProducts(),
          EditProductScreen.routeName: (ctx) => const EditProductScreen(),
        },
      ),
    );
  }
}