import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/products_items_provider.dart';
import '../widgets/error_dialog.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // It may not need to manage FocusNode manually as it seems that it works automatically with just this 'textInputAction: TextInputAction.next',
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final _validationMessage = 'Please provide a value for the';
  var _appBarTitle = 'Add Product';
  var _editedProduct = ProductProvider(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _updateProduct(String field, String value) {
    _editedProduct = ProductProvider(
      id: _editedProduct.id,
      title: field == 'title' ? value : _editedProduct.title,
      description: field == 'description' ? value : _editedProduct.description,
      price: field == 'price' ? double.parse(value) : _editedProduct.price,
      imageUrl: field == 'imageUrl' ? value : _editedProduct.imageUrl,
      isFavourite: _editedProduct.isFavourite,
    );
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_editedProduct.id != null) {
        await Provider.of<ProductItemsProvider>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await Provider.of<ProductItemsProvider>(context, listen: false).addProduct(_editedProduct);
      }
    } catch (error) {
      await ErrorDialog.showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        _editedProduct = Provider.of<ProductItemsProvider>(context, listen: false).findById(productId);
        _imageUrlController.text = _editedProduct.imageUrl;
        _appBarTitle = 'Edit Product';
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _editedProduct.title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          // Return null is everything is ok
                          if (value.isEmpty) {
                            return '$_validationMessage title.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _updateProduct('title', value);
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct.price <= 0 ? '' : _editedProduct.price.toString(),
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\-?\d*\.?\d*)'))],
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          // Return null is everything is ok
                          if (value.isEmpty) {
                            return '$_validationMessage price.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _updateProduct('price', value);
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct.description,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          // Return null is everything is ok
                          if (value.isEmpty) {
                            return '$_validationMessage description.';
                          }
                          if (value.length < 15) {
                            return 'Description needs to be at least 15 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _updateProduct('description', value);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Image Preview')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocusNode,
                              controller: _imageUrlController,
                              validator: (value) {
                                // Return null is everything is ok
                                if (value.isEmpty) {
                                  return '$_validationMessage image URL.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                setState(() {});
                                _saveForm();
                              },
                              onSaved: (value) {
                                _updateProduct('imageUrl', value);
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
