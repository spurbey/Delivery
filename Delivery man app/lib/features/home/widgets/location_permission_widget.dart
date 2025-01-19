import 'package:flutter/material.dart';
import 'package:resturant_delivery_boy/localization/language_constrants.dart';

class LocationPermissionWidget extends StatelessWidget {
  final bool isDenied;
  final Function onPressed;
  const LocationPermissionWidget({Key? key, required this.isDenied, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(getTranslated('alert', context)!),
      content: Text(getTranslated(isDenied ? 'you_denied' : 'you_denied_forever', context)!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: [ElevatedButton(
        onPressed: onPressed as void Function()?,
        child: Text(getTranslated(isDenied ? 'ok' : 'settings', context)!),
      )],
    );
  }
}
