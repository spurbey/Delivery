import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/address/domain/models/address_model.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/common/models/response_model.dart';
import 'package:flutter_restaurant/features/address/domain/models/prediction_model.dart';
import 'package:flutter_restaurant/features/address/domain/reposotories/location_repo.dart';
import 'package:flutter_restaurant/helper/api_checker_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/places.dart';

import '../widgets/permission_dialog_widget.dart';

class LocationProvider with ChangeNotifier {
  final SharedPreferences? sharedPreferences;
  final LocationRepo? locationRepo;

  LocationProvider({required this.sharedPreferences, this.locationRepo});

  Position _position = Position(
    longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1,
    altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
  );
  Position _pickPosition = Position(
    longitude: 0, latitude: 0, timestamp: DateTime.now(), accuracy: 1,
    altitude: 1, heading: 1, speed: 1, speedAccuracy: 1, altitudeAccuracy: 1, headingAccuracy: 1,
  );

  GoogleMapController? mapController;
  CameraPosition? cameraPosition;

  bool _loading = false;
  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;
  String? _address = '';
  String? _pickAddress = '';
  String? _pickedAddressLatitude;
  String? _pickedAddressLongitude;
  int _selectedAreaID = -1;

  String? _currentAddress;
  final List<Marker> _markers = <Marker>[];

  String? get address => _address;
  String? get pickAddress => _pickAddress;

  set setAddress(String value)=> _address = value;



  List<Marker> get markers => _markers;
  bool _buttonDisabled = true;
  bool _changeAddress = true;
  List<PredictionModel> _predictionList = [];
  bool _updateAddAddressData = true;
  bool get buttonDisabled => _buttonDisabled;
  String? get currentAddress => _currentAddress;
  String? get pickedAddressLatitude => _pickedAddressLatitude;
  String? get pickedAddressLongitude => _pickedAddressLongitude;
  int? get selectedAreaID => _selectedAreaID;



  setPickedAddressLatLon(String? lat, String? lon, {bool isUpdate = true}){
    _pickedAddressLatitude = lat;
    _pickedAddressLongitude = lon;
    if(isUpdate){
      notifyListeners();
    }
  }


  updateAddressStatusMessage({String? message}){
    _addressStatusMessage = message;
  }

  void checkPermission(Function callback, {bool canBeIgnoreDialog = false}) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }else if(permission == LocationPermission.deniedForever && !canBeIgnoreDialog) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => const PermissionDialogWidget());
    }else {
      callback();
    }
  }


  // for get current location
  Future<String?> getCurrentLocation(BuildContext context, bool isUpdate, {GoogleMapController? mapController}) async {
    _loading = true;
   if(isUpdate) {
     notifyListeners();
   }

    Position myPosition;
    try {
      Position newLocalData = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      myPosition = newLocalData;
    }catch(e) {
      myPosition = Position(
        latitude: double.parse('0'),
        longitude: double.parse('0'),
        timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
        altitudeAccuracy: 1, headingAccuracy: 1,

      );
    }
    _position = myPosition;

    if (mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(myPosition.latitude, myPosition.longitude), zoom: 17),
      ));
    }
    // String _myPlaceMark;
    _address = await getAddressFromGeocode(LatLng(myPosition.latitude, myPosition.longitude));


    _loading = false;
    notifyListeners();

    return _address;

  }

  // update Position
  void updatePosition(CameraPosition? position, bool fromAddress, String? address, BuildContext context, bool forceNotify, {bool isUpdate = true}) async {
    print('----------update posi-------');
    if(_updateAddAddressData || forceNotify) {
      _loading = true;
      if(isUpdate){
        notifyListeners();
      }
      try {
        if (fromAddress) {
          _position = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
            altitudeAccuracy: 1, headingAccuracy: 1,
          );
        } else {
          _pickPosition = Position(
            latitude: position!.target.latitude, longitude: position.target.longitude, timestamp: DateTime.now(),
            heading: 1, accuracy: 1, altitude: 1, speedAccuracy: 1, speed: 1,
            altitudeAccuracy: 1, headingAccuracy: 1,
          );
        }
        if (_changeAddress) {
          String addressFromGeocode = await getAddressFromGeocode(LatLng(position.target.latitude, position.target.longitude));
          fromAddress ? _address = addressFromGeocode : _pickAddress = addressFromGeocode;
        } else {
          _changeAddress = true;
        }
      } catch (e) {
        debugPrint('error ===> $e');
      }
      _loading = false;
      if(isUpdate || _changeAddress){
        notifyListeners();
      }
    }else {
      _updateAddAddressData = true;
    }
    print("Lat in IDLE and position picked : ${_position.latitude} and ${_position.longitude}");
    print("Lat in IDLE and picked: ${_pickPosition.latitude} and ${_pickPosition.longitude}");
  }

  // delete user address
  Future<void> deleteUserAddressByID(int? id, int index, Function callback) async {
    _isLoading = true;
    notifyListeners();

    ApiResponseModel apiResponse = await locationRepo!.removeAddressByID(id);

    _isLoading = false;
    notifyListeners();

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList!.removeAt(index);
      callback(true, 'Deleted address successfully');
    } else {
      callback(false, ApiCheckerHelper.getError(apiResponse).errors![0].message);
    }

  }

  final bool _isAvailableLocation = false;

  bool get isAvailableLocation => _isAvailableLocation;

  // user address
  List<AddressModel>? _addressList;

  List<AddressModel>? get addressList => _addressList;

  Future<List<AddressModel>?> initAddressList() async {
    ResponseModel? responseModel;
    ApiResponseModel apiResponse = await locationRepo!.getAllAddress(
      guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
    );
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _addressList = [];

      apiResponse.response!.data.forEach((address) => _addressList!.add(AddressModel.fromJson(address)));
      responseModel = ResponseModel(true, 'successful');
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }
    notifyListeners();
    return _addressList;
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _errorMessage = '';
  String? get errorMessage => _errorMessage;
  String? _addressStatusMessage = '';
  String? get addressStatusMessage => _addressStatusMessage;

  updateErrorMessage({String? message}){
    _errorMessage = message;
  }

  Future<ResponseModel> addAddress(AddressModel addressModel) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponseModel apiResponse = await locationRepo!.addAddress(
      addressModel, guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
    );
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      await initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {
      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  /// for address update screen
  Future<ResponseModel> updateAddress(BuildContext context, {required AddressModel addressModel, int? addressId}) async {
    _isLoading = true;
    notifyListeners();
    _errorMessage = '';
    _addressStatusMessage = null;
    ApiResponseModel apiResponse = await locationRepo!.updateAddress(addressModel, addressId);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      initAddressList();
      String? message = map["message"];
      responseModel = ResponseModel(true, message);
      _addressStatusMessage = message;
    } else {

      _errorMessage = ApiCheckerHelper.getError(apiResponse).errors![0].message;
      responseModel = ResponseModel(false, _errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  /// for save user address Section
  Future<void> saveUserAddress({Placemark? address}) async {
    String userAddress = jsonEncode(address);
    try {
      await sharedPreferences!.setString(AppConstants.userAddress, userAddress);
    } catch (e) {
      rethrow;
    }
  }

  String getUserAddress() {
    return sharedPreferences!.getString(AppConstants.userAddress) ?? "";
  }

  bool _saveAsDefaultAddress = false;
  bool get saveAsDefaultAddress => _saveAsDefaultAddress;

  void setDefaultAddress(bool save) {
    _saveAsDefaultAddress = save;
    debugPrint('Save as default address: $saveAsDefaultAddress');

    notifyListeners();
  }

  /// for Label Us
  List<String> _getAllAddressType = [];

  List<String> get getAllAddressType => _getAllAddressType;
  int _selectAddressIndex = 0;

  int get selectAddressIndex => _selectAddressIndex;

  updateAddressIndex(int index, bool notify) {
    _selectAddressIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  initializeAllAddressType({BuildContext? context}) {
    if (_getAllAddressType.isEmpty) {
      _getAllAddressType = [];
      _getAllAddressType = locationRepo!.getAllAddressType(context: context);
    }
  }

  void setLocation(String? placeID, String? address, GoogleMapController? mapController) async {
    _loading = true;
    notifyListeners();
    PlacesDetailsResponse detail;
    ApiResponseModel response = await locationRepo!.getPlaceDetails(placeID);
    detail = PlacesDetailsResponse.fromJson(response.response!.data);

    _pickPosition = Position(
      longitude: detail.result.geometry!.location.lat, latitude: detail.result.geometry!.location.lng,
      timestamp: DateTime.now(), accuracy: 1, altitude: 1, heading: 1, speed: 1, speedAccuracy: 1,
      altitudeAccuracy: 1, headingAccuracy: 1,
    );

    // _pickAddress = Placemark(name: address);
     _pickAddress = address;
     _address = address;
    _changeAddress = false;

    if(mapController != null) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
        detail.result.geometry!.location.lat, detail.result.geometry!.location.lng,
      ), zoom: 16)));
    }
    _loading = false;
    notifyListeners();
  }

  void disableButton() {
    _buttonDisabled = true;
    notifyListeners();
  }

  void setAddAddressData() {
    _position = _pickPosition;
    _address = _pickAddress;
    // _address = placeMarkToAddress(_address);
    _updateAddAddressData = false;
    notifyListeners();
  }



  void setPickData() {
    _pickPosition = _position;
    _pickAddress = _address;
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    ApiResponseModel response = await locationRepo!.getAddressFromGeocode(latLng);
    String address = '';
    if(response.response?.statusCode == 200 && response.response!.data['status'] == 'OK') {
      address = response.response!.data['results'][0]['formatted_address'].toString();
    }
    return address;
  }

  Future<List<PredictionModel>> searchLocation(BuildContext context, String text) async {
    if(text.isNotEmpty) {
      ApiResponseModel response = await locationRepo!.searchLocation(text);

      if (response.response?.statusCode == 200) {
        _predictionList = [];
        response.response?.data['predictions'].forEach((prediction) => _predictionList.add(PredictionModel.fromJson(prediction)));

      } else {
        ApiCheckerHelper.checkApi(response);
      }
    }
    return _predictionList;
  }

  Future<LatLng?> getCurrentLatLong() async {
    Position? position;
    try{
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }catch(e) {
      debugPrint('error : $e');
    }
    return position != null ?  LatLng(position.latitude, position.longitude) : null;
  }

  int? getAddressIndex(AddressModel address){
    int? index;
    if(_addressList != null) {
      for(int i = 0; i < _addressList!.length; i ++) {
        if(_addressList![i].id == address.id) {
          index = i;
          break;
        }
      }
    }
    return index;
  }

  bool _isDefault = false;
  bool get isDefault => _isDefault;

  void onChangeDefaultStatus(bool status, {bool isUpdate = true}) {
    _isDefault = status;

    if(isUpdate) {
      notifyListeners();
    }

  }

  Future<AddressModel?> getDefaultAddress() async {
    AddressModel? addressModel;

    ApiResponseModel response = await locationRepo!.getDefaultAddress();
    if (response.response?.statusCode == 200 && response.response?.data != null) {
      addressModel = AddressModel.fromJson(response.response?.data);
    } else {
      ApiCheckerHelper.checkApi(response);
    }

    return addressModel;
  }

  void onChangePosition(Position value) {
    _position = value;

  }

  void onChangeCurrentAddress(String? address, {bool isUpdate = false}){
    _currentAddress = address;

    if(isUpdate) {
      notifyListeners();
    }
  }

  void setAreaID({int? areaID, bool isUpdate = true, bool isReload = false}) {
    if(isReload){
      _selectedAreaID = -1;
    }else{
      _selectedAreaID = areaID!;
    }
    if(isUpdate){
      notifyListeners();
    }
  }

}
