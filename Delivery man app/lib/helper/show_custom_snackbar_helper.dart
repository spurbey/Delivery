import 'package:flutter/material.dart';
import 'package:resturant_delivery_boy/main.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';


enum SnackBarStatus {error, success, alert, info}

void showCustomSnackBarHelper(String? message, {
  bool isError = true, bool isToast = false}) {

  final Size size = MediaQuery.of(Get.context!).size;

  ScaffoldMessenger.of(Get.context!)..hideCurrentSnackBar()..showSnackBar(SnackBar(
    elevation: 0,
    shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: Colors.transparent)
    ),
    content: Align(alignment: Alignment.center,
      child: Material(color: Colors.black, elevation: 0, borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [


            CircleAvatar(
              radius: 12, // Adjust radius as needed
              backgroundColor: isError ? Colors.red : Colors.green, // Background color of the circle
              child: Icon(
                isError ? Icons.close_rounded : Icons.check,
                color: Colors.white,
                size: 16, // Icon size
              ),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            Flexible(child: Text(
              message ?? '',
              style: rubikBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeDefault,
              ),
              textAlign: TextAlign.center,
            )),

          ]),
        ),
      ),
    ),
    margin: EdgeInsets.only(bottom: size.height * 0.08),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,

  ));

}