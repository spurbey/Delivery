import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/cart_model.dart';
import 'package:flutter_restaurant/common/models/product_model.dart';
import 'package:flutter_restaurant/common/providers/product_provider.dart';
import 'package:flutter_restaurant/features/cart/domain/reposotories/cart_repo.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

class CartProvider extends ChangeNotifier {
  final CartRepo? cartRepo;
  CartProvider({required this.cartRepo});

  List<CartModel?> _cartList = [];
  double _amount = 0.0;
  bool _isCartUpdate = false;

  List<CartModel?> get cartList => _cartList;
  double get amount => _amount;
  bool get isCartUpdate => _isCartUpdate;


  void getCartData(BuildContext context) {
    _cartList = [];
    _cartList.addAll(cartRepo!.getCartList(context));
    for (var cart in _cartList) {
      _amount = _amount + (cart!.discountedPrice! * cart.quantity!);
    }
  }

  void addToCart(CartModel cartModel, int? index) {
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      _cartList.add(cartModel);
    }
    cartRepo!.addToCartList(_cartList);
    setCartUpdate(false);
    showCustomSnackBarHelper(getTranslated(index == -1 ?
    'added_in_cart' : 'cart_updated', Get.context!), isToast: true, isError: false);

    notifyListeners();
  }

  void setQuantity(
      {required bool isIncrement,
      CartModel? cart,
      int? productIndex,
      required bool fromProductView}) {
    int? index = fromProductView ? productIndex :  _cartList.indexOf(cart);
    if (isIncrement) {
      _cartList[index!]!.quantity = _cartList[index]!.quantity! + 1;
      _amount = _amount + _cartList[index]!.discountedPrice!;
    } else {
      _cartList[index!]!.quantity = _cartList[index]!.quantity! - 1;
      _amount = _amount - _cartList[index]!.discountedPrice!;
    }
    cartRepo!.addToCartList(_cartList);

    notifyListeners();
  }

  void removeFromCart(int index) {
    _amount = _amount - (_cartList[index]!.discountedPrice! * _cartList[index]!.quantity!);
    _cartList.removeAt(index);
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index]!.addOnIds!.removeAt(addOnIndex);
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  void clearCartList() {
    _cartList = [];
    _amount = 0;
    cartRepo!.addToCartList(_cartList);
    notifyListeners();
  }

  int isExistInCart(int? productID, int? cartIndex) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index]!.product!.id == productID) {
        if((index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }


  int getCartIndex (Product product) {
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index]!.product!.id == product.id ) {

        return index;
      }
    }
    return -1;
  }
  int getCartProductQuantityCount (Product product) {
    int quantity = 0;
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index]!.product!.id == product.id ) {
        quantity = quantity + (_cartList[index]!.quantity ?? 0);
      }
    }
    return quantity;
  }


  setCartUpdate(bool isUpdate) {
    _isCartUpdate = isUpdate;
    if(_isCartUpdate) {
      notifyListeners();
    }

  }

  void onUpdateCartQuantity({required int index, required Product product,  required bool isRemove}) {

    if(!_isProductInCart(product)) {
      final ProductProvider productProvider = Provider.of<ProductProvider>(Get.context!, listen: false);
      int quantity = getCartProductQuantityCount(product) + (isRemove ? -1 : 1);


      if(!isRemove && productProvider.checkStock(product, quantity: quantity) || isRemove) {

        if(isRemove && quantity == 0) {
          removeFromCart(index);
          showCustomSnackBarHelper(getTranslated('this_item_removed_form_cart', Get.context!));

        }else {
          _cartList[index]?.quantity = quantity;
          addToCart(_cartList[index]!, index);

        }
      }else {
        showCustomSnackBarHelper(getTranslated('out_of_stock', Get.context!));

      }
    }else{
      showCustomSnackBarHelper(getTranslated('update_quantity_from_cart_list', Get.context!));
    }

  }

  bool _isProductInCart(Product product){
    int count = 0;
    for(int index = 0; index < _cartList.length; index ++) {
      if(_cartList[index]!.product!.id == product.id ) {
        count++;
        if(count > 1) {
          return true;
        }
      }
    }
    return false;

  }

}
