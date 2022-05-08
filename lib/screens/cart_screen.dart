import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/providers/cart_provider.dart';
import 'package:my_shop/providers/order_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    final cartsValue = cartData.carts.values.toList();
    final orderDate = Provider.of<OrdersProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CartsList(cartsValue: cartsValue, cartData: cartData),
          Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            shadowColor: Colors.black,
            elevation: 500,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Total Price',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    child: Chip(
                      label:
                          Text('\$${cartData.totalPrice.toStringAsFixed(2)}'),
                      labelStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  OrderButton(
                      orderDate: orderDate,
                      cartData: cartData,
                      cartsValue: cartsValue),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CartsList extends StatelessWidget {
  const CartsList({
    Key? key,
    required this.cartsValue,
    required this.cartData,
  }) : super(key: key);

  final List<Cart> cartsValue;
  final CartProvider cartData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, i) => Dismissible(
        key: ValueKey(cartsValue[i].id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) =>
            cartData.delete(cartData.carts.keys.toList()[i]),
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Are you sure'),
              content: const Text('Do you want to remove this item'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('no'),
                ),
              ],
            ),
          );
        },
        background: Container(
          padding: const EdgeInsetsDirectional.only(end: 16),
          alignment: AlignmentDirectional.centerEnd,
          color: Theme.of(context).errorColor,
          child: const Text(
            'remove',
            style: TextStyle(fontSize: 18),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    cartsValue[i].imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(start: 20),
                  height: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          cartsValue[i].title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyy hh:mm a')
                              .format(cartsValue[i].date),
                        ),
                        trailing: Text(
                          'x${cartsValue[i].quantity}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsetsDirectional.only(
                          start: 16,
                          bottom: 8,
                        ),
                        child: Text(
                          '\$${cartsValue[i].price}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      itemCount: cartsValue.length,
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.orderDate,
    required this.cartData,
    required this.cartsValue,
  }) : super(key: key);

  final OrdersProvider orderDate;
  final CartProvider cartData;
  final List<Cart> cartsValue;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          onPressed: widget.cartData.totalPrice == 0
              ? null
              : () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    await widget.orderDate.addOrder(
                      total: widget.cartData.totalPrice,
                      carts: widget.cartsValue,
                    );
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Ordered successfully');
                  } catch (e) {
                    print('Error adding the cart to orders $e');
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Error adding them to orders');
                  }
                  try {
                    await widget.cartData.clearCart();
                    setState(() {
                      _isLoading = false;
                    });
                  } catch (e) {
                    print('Error clearing the cart $e');
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(msg: 'Error clearing the cart');
                  }
                },
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const FittedBox(
                  child: Text(
                    'Order now',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
