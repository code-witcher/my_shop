import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/providers/order_provider.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  static const routeName = '/order-screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  var _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).fetchOrders().then((value) => _isLoading = false).catchError((e) {
      print('Error fetching orders on order_screen $e');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrdersProvider>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemBuilder: (ctx, i) => OrderWidget(i, orderData),
              itemCount: orderData.length,
            ),
    );
  }
}

class OrderWidget extends StatefulWidget {
  const OrderWidget(this.index, this.orderData, {Key? key}) : super(key: key);
  final int index;
  final List<Order> orderData;

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Order: (${widget.orderData.length - widget.index})\t '
              '\$${widget.orderData[widget.index].total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyy hh:mm a')
                  .format(widget.orderData[widget.index].date),
            ),
            trailing: IconButton(
              icon: Icon(
                expanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            ),
          ),
          if (expanded) const Divider(),
          if (expanded)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              height:
                  min(widget.orderData[widget.index].carts.length * 70, 180),
              child: ListView.builder(
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      widget.orderData[widget.index].carts[i].imageUrl,
                    ),
                  ),
                  title: Text(
                    widget.orderData[widget.index].carts[i].title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: Container(
                    width: 120,
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            child: Text(
                              '${widget.orderData[widget.index].carts[i].quantity}x',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: FittedBox(
                              child: Text(
                                '\$${widget.orderData[widget.index].carts[i].price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                itemCount: widget.orderData[widget.index].carts.length,
              ),
            ),
        ],
      ),
    );
  }
}
