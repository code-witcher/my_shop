import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_shop/providers/auth_provider.dart';
import 'package:my_shop/providers/cart_provider.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:my_shop/screens/product_details_screen.dart';
import 'package:provider/provider.dart';

class ProductItemWidget extends StatelessWidget {
  const ProductItemWidget(this._productData, {Key? key}) : super(key: key);

  final Product _productData;

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailsScreen.routeName,
            arguments: _productData.id,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridTile(
                header: Container(
                  alignment: AlignmentDirectional.topStart,
                  child: Consumer<Product>(
                    builder: (ctx, product, child) {
                      return IconButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () async {
                          try {
                            await product.toggleFavorites(
                              auth.token,
                              auth.userId,
                            );
                            Fluttertoast.cancel();
                            Fluttertoast.showToast(
                                msg: product.isFavorite
                                    ? 'One item Added to favorites'
                                    : 'One item removed from favorites');
                          } catch (e) {
                            print('error on adding item to favorites $e');
                            Fluttertoast.cancel();
                            Fluttertoast.showToast(
                                msg: product.isFavorite
                                    ? 'Failed to remove from favorites'
                                    : 'Failed to add to favorites');
                          }
                        },
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Theme.of(context).accentColor,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    _productData.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(_productData.title),
              subtitle: Text(_productData.price.toString()),
              trailing: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: IconButton(
                  onPressed: () {
                    cartData.addItem(
                      productId: _productData.id,
                      title: _productData.title,
                      imageUrl: _productData.imageUrl,
                      price: _productData.price,
                    );
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('One item added to cart'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            cartData.deleteOneItem(_productData.id);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
