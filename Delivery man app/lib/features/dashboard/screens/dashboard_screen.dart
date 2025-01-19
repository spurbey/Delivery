import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_pop_scope_widget.dart';
import 'package:resturant_delivery_boy/features/order/providers/order_provider.dart';
import 'package:resturant_delivery_boy/features/profile/providers/profile_provider.dart';
import 'package:resturant_delivery_boy/helper/location_helper.dart';
import 'package:resturant_delivery_boy/helper/notification_helper.dart';
import 'package:resturant_delivery_boy/localization/language_constrants.dart';
import 'package:resturant_delivery_boy/features/home/screens/home_screen.dart';
import 'package:resturant_delivery_boy/features/order/screens/order_history_screen.dart';
import 'package:resturant_delivery_boy/features/profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late List<Widget> _screens;

  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];


    _listener = AppLifecycleListener(
      onResume: stopService,
    );

    _loadData();




  }

  Future<void> _loadData() async {

    Provider.of<OrderProvider>(context, listen: false).getCurrentOrdersList(1, context);
    Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
    Provider.of<OrderProvider>(context, listen: false).getDeliveryOrderStatistics(isUpdate: false);
    Provider.of<OrderProvider>(context, listen: false).setDeliveryAnalyticsTimeRangeEnum(isReload: true, isUpdate: false);
    Provider.of<OrderProvider>(context, listen: false).setSelectedSectionID(isReload: true, isUpdate: false);
    Provider.of<OrderProvider>(context, listen: false).getOrderHistoryList(1, context, isUpdate: false, isReload: true);

    await LocationHelper.checkPermission(context);

    _disableBatteryOptimization();


  }

  Future _disableBatteryOptimization() async {
    bool isDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

    if(!isDisabled) {
      DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      isExit: _pageIndex == 0,
      onPopInvoked: (){
        if(_pageIndex != 0) {
          _setPage(0);
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).hintColor.withOpacity(0.7),
          backgroundColor: Theme.of(context).cardColor,
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            _barItem(Icons.home, getTranslated('home', context), 0),
            _barItem(Icons.history, getTranslated('order_history', context), 1),
            _barItem(Icons.person, getTranslated('profile', context), 2),
          ],
          onTap: (int index) {
            _setPage(index);
          },
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(IconData icon, String? label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: index == _pageIndex ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withOpacity(0.7), size: 20),
      label: label,
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
