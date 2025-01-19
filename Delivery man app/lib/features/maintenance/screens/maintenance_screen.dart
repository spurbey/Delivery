import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resturant_delivery_boy/common/models/config_model.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_asset_image_widget.dart';
import 'package:resturant_delivery_boy/features/home/screens/home_screen.dart';
import 'package:resturant_delivery_boy/features/splash/providers/splash_provider.dart';
import 'package:resturant_delivery_boy/localization/language_constrants.dart';
import 'package:resturant_delivery_boy/main.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/images.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);


  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with WidgetsBindingObserver{

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
      splashProvider.initConfig(context).then((bool isSuccess) {
        if(isSuccess){
          final config = splashProvider.configModel!;
          if(config.maintenanceMode?.maintenanceStatus == 0) {
            Navigator.of(Get.context!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false
            );
          }
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final ConfigModel? configModel = Provider.of<SplashProvider>(context).configModel;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.025),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              const CustomAssetImageWidget(Images.maintenanceSvg, width: 200, height: 200),
              SizedBox(height: size.height * 0.07),

              if(configModel != null) ... [

                if(configModel.maintenanceMode?.maintenanceMessages?.maintenanceMessage != null && configModel.maintenanceMode!.maintenanceMessages!.maintenanceMessage!.isNotEmpty)...[
                  Text(configModel.maintenanceMode?.maintenanceMessages?.maintenanceMessage ?? "",
                    textAlign: TextAlign.center,
                    style: rubikBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyMedium?.color
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],

                if(configModel.maintenanceMode?.maintenanceMessages?.messageBody != null && configModel.maintenanceMode!.maintenanceMessages!.messageBody!.isNotEmpty)...[
                  Text(configModel.maintenanceMode?.maintenanceMessages?.messageBody ?? "",
                    textAlign: TextAlign.center,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],




                if(configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1 ||
                    configModel.maintenanceMode?.maintenanceMessages?.businessNumber == 1) ...[


                  if( (configModel.maintenanceMode?.maintenanceMessages?.maintenanceMessage != null && configModel.maintenanceMode!.maintenanceMessages!.maintenanceMessage!.isNotEmpty) ||
                      (configModel.maintenanceMode?.maintenanceMessages?.messageBody != null && configModel.maintenanceMode!.maintenanceMessages!.messageBody!.isNotEmpty)) ...[

                    Row(
                      children: List.generate(size.width ~/10, (index) => Expanded(
                        child: Container(
                          color: index%2==0?Colors.transparent
                              :Theme.of(context).hintColor.withOpacity(0.2),
                          height: 2,
                        ),
                      )),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  ],


                  Text(getTranslated('any_query_feel_free_to_call', context)!,
                    style: rubikRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),


                  if(configModel.maintenanceMode?.maintenanceMessages?.businessNumber == 1)...[
                    InkWell(
                      onTap: (){
                        launchUrl(Uri.parse(
                          'tel:${Provider.of<SplashProvider>(context, listen: false).configModel!.restaurantPhone}',
                        ), mode: LaunchMode.externalApplication);
                      },
                      child: Text(configModel.restaurantPhone ?? "",
                        style: rubikRegular.copyWith(
                          color: Theme.of(context).indicatorColor,
                          fontSize: Dimensions.fontSizeSmall,
                          decoration: TextDecoration.underline,
                          decorationColor:  Theme.of(context).indicatorColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  ],

                  if(configModel.maintenanceMode?.maintenanceMessages?.businessEmail == 1)...[
                    InkWell(
                      onTap: (){
                        launchUrl(Uri.parse(
                          'mailto:${Provider.of<SplashProvider>(context, listen: false).configModel!.restaurantEmail}',
                        ), mode: LaunchMode.externalApplication);
                      },

                      child: Text(configModel.restaurantEmail ?? "",
                        style: rubikRegular.copyWith(
                          color: Theme.of(context).indicatorColor,
                          fontSize: Dimensions.fontSizeSmall,
                          decoration: TextDecoration.underline,
                          decorationColor:  Theme.of(context).indicatorColor,
                        ),
                      ),
                    ),
                  ],



                ]

              ],




            ]),
          ),
        ),
      ),
    );
  }
}
