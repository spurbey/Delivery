class UserInfoModel {
  int? _id;
  String? _fName;
  String? _lName;
  String? _phone;
  String? _email;
  String? _identityNumber;
  String? _identityType;
  String? _identityImage;
  String? _image;
  String? _password;
  String? _createdAt;
  String? _updatedAt;
  String? _authToken;
  String? _fcmToken;
  int? _branchId;
  int? _isActive;
  String? _applicationStatus;
  int? _loginHitCount;
  int? _isTempBlocked;
  String? _languageCode;
  int? _ordersCount;
  int? _deliveredOrdersCount;
  String? _totalOrderAmount;

  UserInfoModel(
      {int? id,
        String? fName,
        String? lName,
        String? phone,
        String? email,
        String? identityNumber,
        String? identityType,
        String? identityImage,
        String? image,
        String? password,
        String? createdAt,
        String? updatedAt,
        String? authToken,
        String? fcmToken,
        int? branchId,
        int? isActive,
        String? applicationStatus,
        int? loginHitCount,
        int? isTempBlocked,
        String? languageCode,
        int? ordersCount,
        int? deliveredOrdersCount,
        String? totalOrderAmount}) {
    if (id != null) {
      _id = id;
    }
    if (fName != null) {
      _fName = fName;
    }
    if (lName != null) {
      _lName = lName;
    }
    if (phone != null) {
      _phone = phone;
    }
    if (email != null) {
      _email = email;
    }
    if (identityNumber != null) {
      _identityNumber = identityNumber;
    }
    if (identityType != null) {
      _identityType = identityType;
    }
    if (identityImage != null) {
      _identityImage = identityImage;
    }
    if (image != null) {
      _image = image;
    }
    if (password != null) {
      _password = password;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
    if (authToken != null) {
      _authToken = authToken;
    }
    if (fcmToken != null) {
      _fcmToken = fcmToken;
    }
    if (branchId != null) {
      _branchId = branchId;
    }
    if (isActive != null) {
      _isActive = isActive;
    }
    if (applicationStatus != null) {
      _applicationStatus = applicationStatus;
    }
    if (loginHitCount != null) {
      _loginHitCount = loginHitCount;
    }
    if (isTempBlocked != null) {
      _isTempBlocked = isTempBlocked;
    }
    if (languageCode != null) {
      _languageCode = languageCode;
    }
    if (ordersCount != null) {
      _ordersCount = ordersCount;
    }
    if (deliveredOrdersCount != null) {
      _deliveredOrdersCount = deliveredOrdersCount;
    }
    if (totalOrderAmount != null) {
      _totalOrderAmount = totalOrderAmount;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get fName => _fName;
  set fName(String? fName) => _fName = fName;
  String? get lName => _lName;
  set lName(String? lName) => _lName = lName;
  String? get phone => _phone;
  set phone(String? phone) => _phone = phone;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get identityNumber => _identityNumber;
  set identityNumber(String? identityNumber) =>
      _identityNumber = identityNumber;
  String? get identityType => _identityType;
  set identityType(String? identityType) => _identityType = identityType;
  String? get identityImage => _identityImage;
  set identityImage(String? identityImage) => _identityImage = identityImage;
  String? get image => _image;
  set image(String? image) => _image = image;
  String? get password => _password;
  set password(String? password) => _password = password;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get updatedAt => _updatedAt;
  set updatedAt(String? updatedAt) => _updatedAt = updatedAt;
  String? get authToken => _authToken;
  set authToken(String? authToken) => _authToken = authToken;
  String? get fcmToken => _fcmToken;
  set fcmToken(String? fcmToken) => _fcmToken = fcmToken;
  int? get branchId => _branchId;
  set branchId(int? branchId) => _branchId = branchId;
  int? get isActive => _isActive;
  set isActive(int? isActive) => _isActive = isActive;
  String? get applicationStatus => _applicationStatus;
  set applicationStatus(String? applicationStatus) =>
      _applicationStatus = applicationStatus;
  int? get loginHitCount => _loginHitCount;
  set loginHitCount(int? loginHitCount) => _loginHitCount = loginHitCount;
  int? get isTempBlocked => _isTempBlocked;
  set isTempBlocked(int? isTempBlocked) => _isTempBlocked = isTempBlocked;
  String? get languageCode => _languageCode;
  set languageCode(String? languageCode) => _languageCode = languageCode;
  int? get ordersCount => _ordersCount;
  set ordersCount(int? ordersCount) => _ordersCount = ordersCount;
  int? get deliveredOrdersCount => _deliveredOrdersCount;
  set deliveredOrdersCount(int? deliveredOrdersCount) =>
      _deliveredOrdersCount = deliveredOrdersCount;
  String? get totalOrderAmount => _totalOrderAmount;
  set totalOrderAmount(String? totalOrderAmount) =>
      _totalOrderAmount = totalOrderAmount;

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _fName = json['f_name'];
    _lName = json['l_name'];
    _phone = json['phone'];
    _email = json['email'];
    _identityNumber = json['identity_number'];
    _identityType = json['identity_type'];
    _identityImage = json['identity_image'];
    _image = json['image'];
    _password = json['password'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _authToken = json['auth_token'];
    _fcmToken = json['fcm_token'];
    _branchId = json['branch_id'];
    _isActive = json['is_active'];
    _applicationStatus = json['application_status'];
    _loginHitCount = json['login_hit_count'];
    _isTempBlocked = json['is_temp_blocked'];
    _languageCode = json['language_code'];
    _ordersCount = json['orders_count'];
    _deliveredOrdersCount = json['delivered_orders_count'];
    _totalOrderAmount = json['total_order_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['f_name'] = _fName;
    data['l_name'] = _lName;
    data['phone'] = _phone;
    data['email'] = _email;
    data['identity_number'] = _identityNumber;
    data['identity_type'] = _identityType;
    data['identity_image'] = _identityImage;
    data['image'] = _image;
    data['password'] = _password;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['auth_token'] = _authToken;
    data['fcm_token'] = _fcmToken;
    data['branch_id'] = _branchId;
    data['is_active'] = _isActive;
    data['application_status'] = _applicationStatus;
    data['login_hit_count'] = _loginHitCount;
    data['is_temp_blocked'] = _isTempBlocked;
    data['language_code'] = _languageCode;
    data['orders_count'] = _ordersCount;
    data['delivered_orders_count'] = _deliveredOrdersCount;
    data['total_order_amount'] = _totalOrderAmount;
    return data;
  }
}