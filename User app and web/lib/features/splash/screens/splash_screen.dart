import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/enums/data_source_enum.dart';
import 'package:flutter_restaurant/common/models/config_model.dart';
import 'package:flutter_restaurant/common/widgets/custom_asset_image_widget.dart';
import 'package:flutter_restaurant/features/auth/providers/auth_provider.dart';
import 'package:flutter_restaurant/features/branch/providers/branch_provider.dart';
import 'package:flutter_restaurant/features/cart/providers/cart_provider.dart';
import 'package:flutter_restaurant/features/onboarding/providers/onboarding_provider.dart';
import 'package:flutter_restaurant/features/splash/providers/splash_provider.dart';
import 'package:flutter_restaurant/helper/custom_snackbar_helper.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/helper/version_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final String? routeTo;
  const SplashScreen({super.key, this.routeTo});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? subscription;

  late AnimationController animationController;
  late Animation<Offset> leftSlideAnimation;
  bool isNotLoaded = true;

  @override
  void initState() {
    super.initState();

    _checkConnectivity();


    _splashAnimation();

    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<CartProvider>(context, listen: false).getCartData(context);

    _route();

  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  void _splashAnimation(){
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);

    leftSlideAnimation = Tween<Offset>(begin: const Offset(-4, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: animationController, curve: Curves.ease),
    );

    animationController.forward();
  }

  void _route() {
    print('--------call-------');

    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    splashProvider.initConfig(context, DataSourceEnum.local).then((value) async {
      _onConfigAction(value, splashProvider, Get.context!);
    });
  }

  void _onConfigAction(ConfigModel? value, SplashProvider splashProvider, BuildContext context) {

    if (value != null) {

      final BranchProvider branchProvider = Provider.of<BranchProvider>(context, listen: false);

      if(branchProvider.getBranchId() != -1){
        splashProvider.getDeliveryInfo(branchProvider.getBranchId());
      }

      final config = splashProvider.configModel!;
      double? minimumVersion;

      if(defaultTargetPlatform == TargetPlatform.android  && config.playStoreConfig != null) {
        minimumVersion = config.playStoreConfig!.minVersion;

      }else if(defaultTargetPlatform == TargetPlatform.iOS  &&  config.appStoreConfig != null) {
        minimumVersion = config.appStoreConfig!.minVersion;
      }

      if(config.maintenanceMode?.maintenanceStatus == 1 && config.maintenanceMode?.selectedMaintenanceSystem?.customerApp == 1) {
        RouterHelper.getMaintainRoute(action: RouteAction.pushNamedAndRemoveUntil);

      }else if(VersionHelper.parse('$minimumVersion') > VersionHelper.parse(AppConstants.appVersion)) {
        RouterHelper.getUpdateRoute(action: RouteAction.pushNamedAndRemoveUntil);
      }else if (Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn()) {
        Provider.of<AuthProvider>(Get.context!, listen: false).updateToken();
        RouterHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);
      } else {
        if(widget.routeTo != null){
          Get.context!.pushReplacement(widget.routeTo!);
        }else{
          Future.delayed(const Duration(milliseconds: 10)).then((v){
            RouterHelper.getLanguageRoute(false, action: RouteAction.pushNamedAndRemoveUntil);
            ResponsiveHelper.isMobile() && Provider.of<OnBoardingProvider>(Get.context!, listen: false).showOnBoardingStatus
                ? RouterHelper.getLanguageRoute(false, action: RouteAction.pushNamedAndRemoveUntil)
                : Provider.of<BranchProvider>(Get.context!, listen: false).getBranchId() != -1
                ?  RouterHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil)
                : RouterHelper.getBranchListScreen(action: RouteAction.pushNamedAndRemoveUntil);
          });

        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<SplashProvider>(
      builder: (context, splashProvider, _) {
        if(splashProvider.configModel != null && isNotLoaded) {
          isNotLoaded = false;
          _onConfigAction(splashProvider.configModel, splashProvider, context);
        }
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: 0.6),
          curve: Curves.ease,
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, widget) => Scaffold(
            backgroundColor: ColorResources.splashBackgroundColor,
            key: _globalKey,
            body: Center(child: Consumer<SplashProvider>(builder: (context, splash, child) {
              return Stack(children: [

                const Align(alignment: Alignment.bottomCenter,
                  child: CustomAssetImageWidget(
                    Images.splashBackground,
                    fit: BoxFit.cover,
                  ),
                ),

                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SlideTransition(
                    position: leftSlideAnimation,
                    child: const CustomAssetImageWidget(
                        Images.logo, height: 60
                    ),
                  ),

                  Text(AppConstants.appName, style: rubikBold.copyWith(fontSize: 68, color: Colors.white), textAlign: TextAlign.center),
                ])),


              ]);
            })),
          ),
        );
      }
    );
  }

  void _checkConnectivity() {
    bool isFirst = true;
    subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi)  || result.contains(ConnectivityResult.mobile);

      if((isFirst && !isConnected) || !isFirst && context.mounted) {
        showCustomSnackBarHelper(getTranslated(isConnected ?  'connected' : 'no_internet_connection', context), isError: !isConnected);

        if(isConnected && ModalRoute.of(context)?.settings.name == RouterHelper.splashScreen) {
          _route();
        }
      }
      isFirst = false;


    });

  }

}





