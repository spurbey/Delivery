import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_asset_image_widget.dart';
import 'package:resturant_delivery_boy/common/widgets/paginated_list_widget.dart';
import 'package:resturant_delivery_boy/features/home/widgets/delivery_analytics_shimmer_widget.dart';
import 'package:resturant_delivery_boy/features/home/widgets/delivery_analytics_widget.dart';
import 'package:resturant_delivery_boy/features/order/domain/models/orders_info_model.dart';
import 'package:resturant_delivery_boy/features/order/providers/order_provider.dart';
import 'package:resturant_delivery_boy/features/order/screens/order_details_screen.dart';
import 'package:resturant_delivery_boy/features/order/widgets/order_card_item_widget.dart';
import 'package:resturant_delivery_boy/features/order/widgets/order_list_shimmer_widget.dart';
import 'package:resturant_delivery_boy/features/profile/providers/profile_provider.dart';
import 'package:resturant_delivery_boy/helper/custom_extension_helper.dart';
import 'package:resturant_delivery_boy/localization/language_constrants.dart';
import 'package:resturant_delivery_boy/utill/app_constants.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/images.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: context.theme.cardColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.06), // Height of the AppBar
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.cardColor, // Background color of the AppBar
            boxShadow: [
              BoxShadow(
                color: context.theme.primaryColor.withOpacity(0.08), // Shadow color
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 4), // Offset of the shadow
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: context.theme.cardColor,
            centerTitle: false,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeSmall,
                bottom: Dimensions.paddingSizeExtraSmall,
              ),
              child: Row(children: [

                const CustomAssetImageWidget(Images.logo,
                  height: 50, width: 50,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                Text(AppConstants.appName, style: rubikBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: context.theme.primaryColor,
                ))

              ]),
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async{
          orderProvider.getCurrentOrdersList(1, context);
          Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
          orderProvider.getDeliveryOrderStatistics(filter: orderProvider.deliveryAnalyticsTimeRangeEnum?.name);
        },
        child: CustomScrollView(controller: scrollController, slivers: [

          SliverToBoxAdapter(child: Selector<OrderProvider, bool>(
            selector: (context, orderProvider)=> orderProvider.isLoading,
            builder: (context, isLoading, child) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                isLoading ? const DeliveryAnalyticsShimmerWidget() : const DeliveryAnalyticsWidget(),

              ]);
            }
          )),

          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                Text(getTranslated('ongoing_orders', context)!,
                  style: rubikBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: context.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Selector<OrderProvider, OrdersInfoModel?>(
                    selector: (context, orderProvider) => orderProvider.currentOrderModel,
                    builder: (context, currentOrderModel, child) {

                      final OrderProvider orderProvider = Provider.of(context, listen: false);

                      return PaginatedListWidget(
                        onPaginate: (int? offset) async {
                          await orderProvider.getCurrentOrdersList(offset ?? 1, context);
                        },
                        scrollController: scrollController,
                        enabledPagination: true,
                        offset: int.parse(currentOrderModel?.offset ?? '0'),
                        totalSize: currentOrderModel?.totalSize,
                        itemView: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderProvider.currentOrders.length,
                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                          itemBuilder: (context, index) => InkWell(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) =>
                                  OrderDetailsScreen(orderModelItem: orderProvider.currentOrders[index])));
                            },
                            child: OrderCardItemWidget(
                              orderModel: orderProvider.currentOrders[index],
                            ),
                          ),
                        ),
                      );
                    }
                )

              ]),
            ),
          )

        ]),
      ),
    );
  }
}








