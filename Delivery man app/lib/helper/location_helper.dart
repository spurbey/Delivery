import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resturant_delivery_boy/features/home/widgets/location_permission_widget.dart';
import 'package:resturant_delivery_boy/main.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationHelper{
  static Future<void> checkPermission(BuildContext context, {Function? callBack}) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (ctx) => LocationPermissionWidget(isDenied: true, onPressed: () async {
        Navigator.pop(context);
        await Geolocator.requestPermission();
        if(callBack != null) {
          checkPermission(Get.context!, callBack: callBack);
        }

      }));
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: Get.context!, barrierDismissible: false, builder: (context) => LocationPermissionWidget(isDenied: false, onPressed: () async {
        Navigator.pop(context);
        await Geolocator.openAppSettings();
        if(callBack != null) {
          checkPermission(Get.context!, callBack: callBack);
        }

      }));
    }else if(callBack != null){
      callBack();
    }
  }

  static Future<void> openMap({required double destinationLatitude, required double destinationLongitude, double? userLatitude, double? userLongitude}) async {
    String googleUrl = 'https://www.google.com/maps/dir/?api=1${userLatitude != null ? '&origin=$userLatitude,$userLongitude' : ''}&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

}