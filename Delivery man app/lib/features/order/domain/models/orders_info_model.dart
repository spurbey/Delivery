import 'package:resturant_delivery_boy/features/order/domain/models/order_model.dart';

class OrdersInfoModel {
  int? _totalSize;
  String? _limit;
  String? _offset;
  List<OrderModel>? _orders;

  OrdersInfoModel(
      {int? totalSize, String? limit, String? offset, List<OrderModel>? orders}) {
    if (totalSize != null) {
      _totalSize = totalSize;
    }
    if (limit != null) {
      _limit = limit;
    }
    if (offset != null) {
      _offset = offset;
    }
    if (orders != null) {
      _orders = orders;
    }
  }

  int? get totalSize => _totalSize;
  set totalSize(int? totalSize) => _totalSize = totalSize;
  String? get limit => _limit;
  set limit(String? limit) => _limit = limit;
  String? get offset => _offset;
  set offset(String? offset) => _offset = offset;
  List<OrderModel>? get orders => _orders;
  set orders(List<OrderModel>? orders) => _orders = orders;

  OrdersInfoModel.fromJson(Map<String, dynamic> json) {
    _totalSize = json['total_size'];
    _limit = json['limit'];
    _offset = json['offset'];
    if (json['orders'] != null) {
      _orders = <OrderModel>[];
      json['orders'].forEach((v) {
        _orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = _totalSize;
    data['limit'] = _limit;
    data['offset'] = _offset;
    if (_orders != null) {
      data['orders'] = _orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
