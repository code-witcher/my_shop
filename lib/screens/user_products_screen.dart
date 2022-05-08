import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:my_shop/screens/edit_products.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class ManageUserProducts extends StatelessWidget {
  const ManageUserProducts({Key? key}) : super(key: key);
  static const routeName = '/manage-products';

  @override
  Widget build(BuildContext context) {
    final prodProvider = Provider.of<ProductsProvider>(context);
    final productsData = prodProvider.products;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
              );
            },
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
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
        },
        child: ListView.builder(
          itemCount: productsData.length,
          itemBuilder: (ctx, i) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(productsData[i].imageUrl),
              ),
              title: Text(productsData[i].title),
              trailing: Container(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          EditProductScreen.routeName,
                          arguments: productsData[i].id,
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          await Provider.of<ProductsProvider>(
                            context,
                            listen: false,
                          ).deleteProduct(productsData[i].id);
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                            msg: 'One item deleted successfully',
                          );
                        } catch (e) {
                          print(
                            'An error occurred on deleting an item from '
                            'server on user_products $e',
                          );
                          Fluttertoast.cancel();
                          Fluttertoast.showToast(
                            msg: 'Failed to delete',
                          );
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).errorColor,
                      ),
                      splashColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
