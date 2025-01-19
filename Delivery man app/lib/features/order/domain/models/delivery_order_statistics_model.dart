class DeliveryOrderStatisticsModel {
  int? _ongoingAssignedOrders;
  int? _confirmedOrders;
  int? _processingOrders;
  int? _outForDeliveryOrders;
  int? _deliveredOrders;
  int? _canceledOrders;
  int? _returnedOrders;
  int? _failedOrders;

  DeliveryOrderStatisticsModel(
      {int? ongoingAssignedOrders,
        int? confirmedOrders,
        int? processingOrders,
        int? outForDeliveryOrders,
        int? deliveredOrders,
        int? canceledOrders,
        int? returnedOrders,
        int? failedOrders}) {
    if (ongoingAssignedOrders != null) {
      _ongoingAssignedOrders = ongoingAssignedOrders;
    }
    if (confirmedOrders != null) {
      _confirmedOrders = confirmedOrders;
    }
    if (processingOrders != null) {
      _processingOrders = processingOrders;
    }
    if (outForDeliveryOrders != null) {
      _outForDeliveryOrders = outForDeliveryOrders;
    }
    if (deliveredOrders != null) {
      _deliveredOrders = deliveredOrders;
    }
    if (canceledOrders != null) {
      _canceledOrders = canceledOrders;
    }
    if (returnedOrders != null) {
      _returnedOrders = returnedOrders;
    }
    if (failedOrders != null) {
      _failedOrders = failedOrders;
    }
  }

  int? get ongoingAssignedOrders => _ongoingAssignedOrders;
  set ongoingAssignedOrders(int? ongoingAssignedOrders) =>
      _ongoingAssignedOrders = ongoingAssignedOrders;
  int? get confirmedOrders => _confirmedOrders;
  set confirmedOrders(int? confirmedOrders) =>
      _confirmedOrders = confirmedOrders;
  int? get processingOrders => _processingOrders;
  set processingOrders(int? processingOrders) =>
      _processingOrders = processingOrders;
  int? get outForDeliveryOrders => _outForDeliveryOrders;
  set outForDeliveryOrders(int? outForDeliveryOrders) =>
      _outForDeliveryOrders = outForDeliveryOrders;
  int? get deliveredOrders => _deliveredOrders;
  set deliveredOrders(int? deliveredOrders) =>
      _deliveredOrders = deliveredOrders;
  int? get canceledOrders => _canceledOrders;
  set canceledOrders(int? canceledOrders) => _canceledOrders = canceledOrders;
  int? get returnedOrders => _returnedOrders;
  set returnedOrders(int? returnedOrders) => _returnedOrders = returnedOrders;
  int? get failedOrders => _failedOrders;
  set failedOrders(int? failedOrders) => _failedOrders = failedOrders;

  DeliveryOrderStatisticsModel.fromJson(Map<String, dynamic> json) {
    _ongoingAssignedOrders = json['ongoing_assigned_orders'];
    _confirmedOrders = json['confirmed_orders'];
    _processingOrders = json['processing_orders'];
    _outForDeliveryOrders = json['out_for_delivery_orders'];
    _deliveredOrders = json['delivered_orders'];
    _canceledOrders = json['canceled_orders'];
    _returnedOrders = json['returned_orders'];
    _failedOrders = json['failed_orders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ongoing_assigned_orders'] = _ongoingAssignedOrders;
    data['confirmed_orders'] = _confirmedOrders;
    data['processing_orders'] = _processingOrders;
    data['out_for_delivery_orders'] = _outForDeliveryOrders;
    data['delivered_orders'] = _deliveredOrders;
    data['canceled_orders'] = _canceledOrders;
    data['returned_orders'] = _returnedOrders;
    data['failed_orders'] = _failedOrders;
    return data;
  }
}