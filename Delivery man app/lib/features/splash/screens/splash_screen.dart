import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_button_widget.dart';
import 'package:resturant_delivery_boy/features/language/providers/localization_provider.dart';
import 'package:resturant_delivery_boy/features/maintenance/screens/maintenance_screen.dart';
import 'package:resturant_delivery_boy/helper/notification_helper.dart';
import 'package:resturant_delivery_boy/utill/app_constants.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';
import 'package:resturant_delivery_boy/features/auth/providers/auth_provider.dart';
import 'package:resturant_delivery_boy/features/splash/providers/splash_provider.dart';
import 'package:resturant_delivery_boy/utill/images.dart';
import 'package:resturant_delivery_boy/features/auth/screens/login_screen.dart';
import 'package:resturant_delivery_boy/features/dashboard/screens/dashboard_screen.dart';
import 'package:resturant_delivery_boy/features/language/screens/choose_language_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() {
    SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    splashProvider.initSharedData();

    splashProvider.initConfig(context).then((bool isSuccess) {
      if (isSuccess) {
        splashProvider.getPolicyPage();

        Timer(const Duration(seconds: 1), () async {

          if(splashProvider.configModel?.maintenanceMode?.maintenanceStatus == 1 && splashProvider.configModel?.maintenanceMode?.selectedMaintenanceSystem?.deliverymanApp == 1) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MaintenanceScreen()), (route) => false);
          }
          else if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
            Provider.of<AuthProvider>(context, listen: false).updateToken();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));

          } else if(Provider.of<LocalizationProvider>(context, listen: false).getLanguageCode().isEmpty){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChooseLanguageScreen()));

          }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));

          }

        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(Images.logo, width: 150)),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Text(AppConstants.appName, style: rubikBold.copyWith(fontSize: 30, color: Theme.of(context).primaryColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
