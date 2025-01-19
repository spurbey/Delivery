import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/order_details_model.dart';
import 'package:flutter_restaurant/common/models/place_order_body.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/order/domain/models/delivery_man_model.dart';
import 'package:flutter_restaurant/features/order/domain/models/order_model.dart';
import 'package:flutter_restaurant/features/order/domain/reposotories/order_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepo? orderRepo;
  final SharedPreferences? sharedPreferences;
  OrderProvider({ required this.sharedPreferences,required this.orderRepo});

  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  OrderModel? _trackModel;
  ResponseModel? _responseModel;
  bool _isLoading = false;
  bool _showCancelled = false;
  DeliveryManModel? _deliveryManModel;
  bool _isRestaurantCloseShow = true;




  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  OrderModel? get trackModel => _trackModel;
  ResponseModel? get responseModel => _responseModel;
  bool get isLoading => _isLoading;
  bool get showCancelled => _showCancelled;
  DeliveryManModel? get deliveryManModel => _deliveryManModel;
  bool get isRestaurantCloseShow => _isRestaurantCloseShow;


  void changeStatus(bool status, {bool notify = false}) {
    _isRestaurantCloseShow = status;
    if(notify) {
      notifyListeners();
    }
  }

  Future<void> getOrderList(BuildContext context) async {
    ApiResponseModel apiResponse = await orderRepo!.getOrderList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _runningOrderList = [];
      _historyOrderList = [];
      apiResponse.response!.data['orders'].forEach((order) {
        OrderModel orderModel = OrderModel.fromJson(order);
        if(orderModel.orderStatus == 'pending' ||
            orderModel.orderStatus == 'processing' ||
            orderModel.orderStatus == 'out_for_delivery' ||
            orderModel.orderStatus == 'confirmed') {

          _runningOrderList!.add(orderModel);

        }else if(orderModel.orderStatus == 'delivered' ||
            orderModel.orderStatus == 'returned' ||
            orderModel.orderStatus == 'failed' ||
            orderModel.orderStatus == 'canceled') {
          _historyOrderList!.add(orderModel);
        }
      });
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID, {String? phoneNumber, bool isApiCheck = true}) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    ApiResponseModel apiResponse;
    if(phoneNumber != null){
      apiResponse = await orderRepo!.orderDetailsWithPhoneNumber(orderID, phoneNumber);
    }else{
      apiResponse = await orderRepo!.getOrderDetails(orderID);
    }

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _orderDetails = [];
      apiResponse.response!.data.forEach((orderDetail) => _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
    } else {
      _orderDetails = [];

      if(isApiCheck) {
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }
    _isLoading = false;
    notifyListeners();
    return _orderDetails;
  }

  Future<void> getDeliveryManData(String? orderID) async {
    ApiResponseModel apiResponse = await orderRepo!.getDeliveryManData(orderID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _deliveryManModel = DeliveryManModel.fromJson(apiResponse.response!.data);
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
  }



  Future<ResponseModel?> trackOrder(String? orderID, {String? phoneNumber, bool isUpdate = false, OrderModel? orderModel, bool fromTracking = true}) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      if(isUpdate){
        notifyListeners();
      }
      ApiResponseModel apiResponse;
      if(phoneNumber != null){
        apiResponse = await orderRepo!.trackOrderWithPhoneNumber(orderID,phoneNumber);
      }else{
        apiResponse = await orderRepo!.trackOrder(
          orderID, guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
        );
      }

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _trackModel = OrderModel.fromJson(apiResponse.response!.data);
        _responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        _trackModel = OrderModel(id: -1);
        _responseModel = ResponseModel(false, ApiCheckerHelper.getError(apiResponse).errors![0].message);
        ApiCheckerHelper.checkApi(apiResponse);
      }
    }else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    _isLoading = false;
    notifyListeners();
    return _responseModel;
  }

  Future<void> placeOrder(PlaceOrderBody placeOrderBody, Function callback, {bool isUpdate = true}) async {
    _isLoading = true;
    if(isUpdate){
      notifyListeners();
    }
    ApiResponseModel apiResponse = await orderRepo!.placeOrder(
      placeOrderBody, guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
    );
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      String? message = apiResponse.response!.data['message'];
      String orderID = apiResponse.response!.data['order_id'].toString();
      callback(true, message, orderID, placeOrderBody.deliveryAddressId);
    } else {
      callback(false, ApiCheckerHelper.getError(apiResponse).errors![0].message, '-1', -1);
    }

    notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }


  void clearPrevData({bool isUpdate = false}) {
    _trackModel = null;
    if(isUpdate){
      notifyListeners();
    }
  }

  void cancelOrder(String orderID, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await orderRepo!.cancelOrder(orderID, Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId());
    _isLoading = false;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      OrderModel? orderModel;
      for (var order in _runningOrderList ?? []) {
        if(order.id.toString() == orderID) {
          orderModel = order;
        }
      }
      _runningOrderList?.remove(orderModel);
      _showCancelled = true;
      callback(apiResponse.response!.data['message'], true, orderID);
    } else {
      callback(ApiCheckerHelper.getError(apiResponse).errors?.first.message, false, '-1');
    }
    notifyListeners();
  }


  Future<void> setPlaceOrder(String placeOrder)async{
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeOrder);
  }
  String? getPlaceOrder(){
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }
  Future<void> clearPlaceOrder()async{
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }

  double getDistanceBetween(LatLng startLatLng, LatLng endLatLng){
    return Geolocator.distanceBetween(
      startLatLng.latitude, startLatLng.longitude, endLatLng.latitude, endLatLng.longitude,
    );
  }

}