import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/models/api_response_model.dart';
import 'package:flutter_restaurant/data/datasource/local/cache_response.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/helper/db_helper.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSyncRepo {
  final DioClient dioClient;
  final SharedPreferences? sharedPreferences;

  DataSyncRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel<T>> fetchData<T>(String uri, DataSourceEnum source) async {
    try {
      return source == DataSourceEnum.client ? await _fetchFromClient<T>(uri) : await _fetchFromLocalCache<T>(uri);
    } catch (e) {
      debugPrint('DataSyncRepo: ===> ${source} $e ($uri)');

      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> _fetchFromClient<T>(String uri) async {
    final response = await dioClient.get(uri);

    // Prepare the cache data
    final cacheData = CacheResponseCompanion(
      endPoint: Value(uri),
      header: Value(jsonEncode(dioClient.dio?.options.headers)),
      response: Value(jsonEncode(response.data)),
    );

    // Cache the data based on the platform
    if (kIsWeb) {
      _cacheResponseWeb(uri, cacheData);
    } else {
      await DbHelper.insertOrUpdate(id: uri, data: cacheData);
    }

    return ApiResponseModel.withSuccess(response as T);
  }

  void _cacheResponseWeb(String uri, CacheResponseCompanion cacheData) {
    final cacheJson = CacheResponseData(
      id: 0,
      endPoint: cacheData.endPoint.value,
      header: cacheData.header.value,
      response: cacheData.response.value,
    ).toJson();
    sharedPreferences?.setString(uri, jsonEncode(cacheJson));
  }

  Future<ApiResponseModel<T>> _fetchFromLocalCache<T>(String uri) async {
    CacheResponseData? cacheData;

    if (kIsWeb) {
      final cachedJson = sharedPreferences?.getString(uri);
      if (cachedJson != null) {
        cacheData = CacheResponseData.fromJson(jsonDecode(cachedJson));
      }
    } else {
      cacheData = await database.getCacheResponseById(uri);
    }

    if (cacheData != null) {
      return ApiResponseModel.withSuccess(cacheData as T);
    } else {
      return ApiResponseModel.withError("No local data found for $uri");
    }
  }
}
