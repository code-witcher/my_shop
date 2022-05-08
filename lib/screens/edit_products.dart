import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_shop/providers/product_provider.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _isInit = true;
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  Map<String, String> _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  Future<dynamic> alertDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An error occurred'),
        content: const Text('Failed to add the item to server'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            icon: Text(
              'Ok',
              style: TextStyle(
                color: Theme.of(context).errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveForms() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    if (_editedProduct.id.isEmpty) {
      try {
        await Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).addProduct(_editedProduct);
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: 'One item added to server');
      } catch (e) {
        print('Error occurred on edit_product during adding item $e');
        await alertDialog();
      }
    } else {
      try {
        await Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).updateProduct(_editedProduct.id, _editedProduct);
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: 'Updated successfully');
      } catch (e) {
        print('Error occurred on edit_product during adding item $e');
        await alertDialog();
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final prodId = ModalRoute.of(context)?.settings.arguments;
      if (prodId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(prodId.toString());
        _initValue = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': '${_editedProduct.price}',
          'imageUrl': _editedProduct.imageUrl,
        };
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedProduct.id.isEmpty ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForms,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Column(
              children: [
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    label: Text('Title'),
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.title),
                  ),
                  initialValue: _initValue['title'],
                  textInputAction: TextInputAction.next,
                  autocorrect: true,
                  autofocus: true,
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: value!,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length < 2) {
                      return 'Title should be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    label: Text('Price'),
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.attach_money),
                  ),
                  initialValue: _initValue['price'],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autocorrect: true,
                  autofocus: true,
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: double.parse(value!),
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid value please enter a valid price';
                    }
                    if (double.tryParse(value)! <= 0) {
                      return 'Please enter a value greater than zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    label: Text('Description'),
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.description),
                  ),
                  initialValue: _initValue['description'],
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  autocorrect: true,
                  autofocus: true,
                  maxLines: 5,
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: value!,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                    );
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 10) {
                      return 'description should be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    label: Text('Image URL'),
                    border: OutlineInputBorder(),
                    icon: Icon(Icons.image),
                  ),
                  initialValue: _initValue['imageUrl'],
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  autocorrect: true,
                  autofocus: true,
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: value!,
                    );
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    if (!value.startsWith('http')) {
                      return 'Invalid URL please enter a valid one';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
