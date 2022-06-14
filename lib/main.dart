import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_shop/models/custom_page_transtion.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/providers/cart_provider.dart';
import 'package:my_shop/providers/order_provider.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_products.dart';
import 'package:my_shop/screens/order_screen.dart';
import 'package:my_shop/screens/product_details_screen.dart';
import 'package:my_shop/screens/products_screen.dart';
import 'package:my_shop/screens/splach_screen.dart';
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
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (ctx) => ProductsProvider(),
          update: (ctx, auth, oldValue) => ProductsProvider()
            ..update(
              auth.token,
              auth.userId,
              oldValue!.products,
            ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (ctx) => CartProvider(),
          update: (ctx, auth, oldValue) => CartProvider()
            ..update(
              auth.token,
              auth.userId,
              oldValue!.carts,
            ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (ctx) => OrdersProvider(),
          update: (ctx, auth, oldValue) => OrdersProvider()
            ..update(
              auth.token,
              auth.userId,
              oldValue!.orders,
            ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authData, child) => MaterialApp(
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
              titleLarge: GoogleFonts.roboto(
                color: Colors.blueGrey.shade900,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: GoogleFonts.macondo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.iOS: CustomPageTransition(),
              TargetPlatform.android: CustomPageTransition(),
            }),
          ),
          home: authData.isAuth
              ? const ProductsScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authSnap) =>
                      authSnap.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailsScreen.routeName: (ctx) =>
                const ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrderScreen.routeName: (ctx) => const OrderScreen(),
            ManageUserProducts.routeName: (ctx) => const ManageUserProducts(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
