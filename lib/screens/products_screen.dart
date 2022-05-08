import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_shop/providers/cart_provider.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/badge.dart';
import 'package:my_shop/widgets/products_widget.dart';
import 'package:provider/provider.dart';

enum Favorite { all, favorite }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  var showFavorite = false;
  var _isLoading = true;

  @override
  void initState() {
    fetchData();
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).fetchData().catchError((e) {
      print('Error fetching carts data on products_screen $e');
    });
    super.initState();
  }

  Future<void> fetchData() async {
    try {
      await Provider.of<ProductsProvider>(
        context,
        listen: false,
      ).fetchProducts();
    } catch (e) {
      print('error fetching data on products_screen: $e');
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'An error occurred');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    List<Product> loadedProducts = productsData.products;
    if (showFavorite) {
      setState(() {
        loadedProducts = productsData.products
            .where((prod) => prod.isFavorite == true)
            .toList();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Glitter',
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (ctx) {
              return [
                const PopupMenuItem(child: Text('All'), value: Favorite.all),
                const PopupMenuItem(
                  child: Text('Favorites'),
                  value: Favorite.favorite,
                ),
              ];
            },
            onSelected: (Favorite value) {
              switch (value) {
                case Favorite.all:
                  setState(() {
                    showFavorite = false;
                  });
                  break;
                case Favorite.favorite:
                  setState(() {
                    showFavorite = true;
                  });
                  break;
              }
            },
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, child) => Badge(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              value: cart.count.toString(),
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: loadedProducts[i],
                    child: ProductItemWidget(
                      loadedProducts[i],
                    ),
                  ),
                  itemCount: loadedProducts.length,
                ),
              ),
            ),
    );
  }
}
