import 'package:flutter/material.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  static const routeName = 'product-details-screen';

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as String;
    final product = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(arguments);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).canvasColor,
        ),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Hero(
              tag: product.id,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    margin: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product.imageUrl,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            product.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          subtitle: Text(
                            product.description,
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '\$${product.price}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
