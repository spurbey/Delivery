import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_image_widget.dart';
import 'package:resturant_delivery_boy/features/order/domain/models/order_details_model.dart';
import 'package:resturant_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:resturant_delivery_boy/features/order/domain/models/orders_info_model.dart';
import 'package:resturant_delivery_boy/features/order/widgets/product_type_widget.dart';
import 'package:resturant_delivery_boy/helper/date_converter_helper.dart';
import 'package:resturant_delivery_boy/helper/location_helper.dart';
import 'package:resturant_delivery_boy/helper/price_converter_helper.dart';
import 'package:resturant_delivery_boy/localization/language_constrants.dart';
import 'package:resturant_delivery_boy/features/auth/providers/auth_provider.dart';
import 'package:resturant_delivery_boy/features/language/providers/localization_provider.dart';
import 'package:resturant_delivery_boy/features/order/providers/order_provider.dart';
import 'package:resturant_delivery_boy/features/splash/providers/splash_provider.dart';
import 'package:resturant_delivery_boy/features/order/providers/time_provider.dart';
import 'package:resturant_delivery_boy/common/providers/tracker_provider.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/images.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';
import 'package:resturant_delivery_boy/common/widgets/custom_button_widget.dart';
import 'package:resturant_delivery_boy/features/chat/screens/chat_screen.dart';
import 'package:resturant_delivery_boy/features/order/screens/order_place_screen.dart';
import 'package:resturant_delivery_boy/features/order/widgets/custom_divider_widget.dart';
import 'package:resturant_delivery_boy/features/order/widgets/complete_order_dialog_widget.dart';
import 'package:resturant_delivery_boy/features/order/widgets/slider_button_widget.dart';
import 'package:resturant_delivery_boy/features/order/widgets/timer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModelItem;
  const OrderDetailsScreen({Key? key, this.orderModelItem}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderModel? orderModel;
  double? deliveryCharge = 0;



  @override
  void initState() {
    orderModel = widget.orderModelItem;

    _loadData();


    super.initState();
  }

  _loadData() {
    if(orderModel?.orderAmount == null) {
      Provider.of<OrderProvider>(context, listen: false).getOrderModel('${orderModel!.id}').then((OrderModel? value) {
        orderModel = value;
        if(orderModel?.orderType == 'delivery') {
          deliveryCharge = orderModel?.deliveryCharge;
        }
      }).then((value) {
        Provider.of<OrderProvider>(context, listen: false).getOrderDetails(orderModel!.id.toString(), context).then((value) {
          Provider.of<TimerProvider>(context, listen: false).countDownTimer(orderModel!, context);
        });
      });
    }else{
      if(orderModel?.orderType == 'delivery') {
        deliveryCharge = orderModel?.deliveryCharge;
      }

      Provider.of<OrderProvider>(context, listen: false).getOrderDetails(orderModel!.id.toString(), context).then((value) {
        Provider.of<TimerProvider>(context, listen: false).countDownTimer(orderModel!, context);
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          getTranslated('order_details', context)!,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Consumer<OrderProvider>(
          builder: (context, order, child) {

            double itemsPrice = 0;
            double discount = 0;
            double tax = 0;
            double addOns = 0;
            double subTotal = 0;
            double totalPrice = 0;
            if (order.orderDetails != null && orderModel!.orderAmount != null) {

              for (var orderDetails in order.orderDetails!) {
                List<double> addonPrices = orderDetails.addOnPrices ?? [];
                List<int> addonsIds = orderDetails.addOnIds != null ? orderDetails.addOnIds! : [];

                if(addonsIds.length == addonPrices.length &&
                    addonsIds.length == orderDetails.addOnQtys?.length){
                  for(int i = 0; i < addonsIds.length; i++){
                    addOns = addOns + (addonPrices[i] * orderDetails.addOnQtys![i]);
                  }
                }

                itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
                discount = discount + (orderDetails.discountOnProduct! * orderDetails.quantity!);
                tax = tax + (orderDetails.taxAmount! * orderDetails.quantity!) + orderDetails.addonTaxAmount!;
              }
              subTotal = itemsPrice + tax + addOns;
              totalPrice = subTotal - discount + deliveryCharge! - orderModel!.couponDiscountAmount!;


            }

            List<OrderPartialPayment> paymentList = [];
            if(orderModel != null && orderModel!.orderPartialPayments != null && orderModel!.orderPartialPayments!.isNotEmpty){
              paymentList = [];
              paymentList.addAll(orderModel!.orderPartialPayments!);

              if(orderModel?.paymentStatus == 'partial_paid'){
                paymentList.add(OrderPartialPayment(
                  paidAmount: 0, paidWith: orderModel!.paymentMethod,
                  dueAmount: orderModel!.orderPartialPayments!.first.dueAmount,
                ));
              }
            }


            return order.orderDetails != null && orderModel?.orderAmount != null ? Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    children: [
                      Row(children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${getTranslated('order_id', context)}', style: rubikRegular),
                              Text(' # ${orderModel!.id}', style: rubikMedium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.watch_later, size: Dimensions.paddingSizeDefault),
                              const SizedBox(width: Dimensions.fontSizeLarge),

                              orderModel?.deliveryTime == null ? Flexible(
                                child: Text(
                                  DateConverterHelper.isoStringToLocalDateOnly(orderModel!.createdAt!),
                                  style: rubikRegular,
                                  maxLines: 2,
                                ),
                              ) : Flexible(
                                child: Text(
                                  DateConverterHelper.deliveryDateAndTimeToDate(orderModel!.deliveryDate!, orderModel!.deliveryTime!, context),
                                  style: rubikRegular,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),

                      if(orderModel!.orderStatus == 'pending'
                          || orderModel!.orderStatus == 'confirmed'
                          || orderModel!.orderStatus == 'processing'
                          || orderModel!.orderStatus == 'out_for_delivery'
                      ) const TimerWidget(),


                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 5, spreadRadius: 1,
                          )],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(getTranslated('customer', context)!, style: rubikRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                )),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: ClipOval(
                              child: CustomImageWidget(
                                placeholder: Images.placeholderUser, height: 40, width: 40, fit: BoxFit.cover,
                                image:'${splashProvider.baseUrls?.customerImageUrl}/${orderModel?.customer?.image}',
                              ),
                            ),
                            title: Text(
                              orderModel!.deliveryAddress == null
                                  ? '' : orderModel!.deliveryAddress!.contactPersonName ?? '',
                              style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                            ),
                            trailing: orderModel?.orderStatus != 'delivered' ?  InkWell(
                              onTap: orderModel?.deliveryAddress != null ?  () async {
                                Uri uri = Uri.parse('tel:${orderModel?.deliveryAddress?.contactPersonNumber}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  throw 'Could not launch $uri';
                                }
                              } : null,
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.fontSizeLarge),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).shadowColor),
                                child:  Icon(Icons.call_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                            ) : null,
                          ),

                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text('${getTranslated('item', context)}:', style: rubikRegular),
                            const SizedBox(width: Dimensions.fontSizeLarge),
                            Text(order.orderDetails!.length.toString(), style: rubikMedium),
                          ]),

                          orderModel!.orderStatus == 'processing' || orderModel!.orderStatus == 'out_for_delivery' ? Row(children: [
                            Text('${getTranslated('payment_status', context)}:', style: rubikRegular),
                            const SizedBox(width: Dimensions.fontSizeLarge),
                            Text(getTranslated('${orderModel!.paymentStatus}', context)!,
                                style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                          ])
                              : const SizedBox.shrink(),
                        ],
                      ),
                      const Divider(height: Dimensions.paddingSizeLarge),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.orderDetails!.length,
                        itemBuilder: (context, index) {
                          List<AddOns> addOns = [];
                          String variationText = '';

                          if(order.orderDetails![index].addOnIds != null){
                            for (var addOnsId in order.orderDetails![index].addOnIds!) {
                              for (var addons in order.orderDetails![index].productDetails!.addOns!) {
                                if(addons.id == addOnsId) {
                                  addOns.add(addons);
                                }
                              }
                            }
                          }

                          if(order.orderDetails![index].variations != null && order.orderDetails![index].variations!.isNotEmpty) {
                            for(Variation variation in order.orderDetails![index].variations!) {
                              variationText += '${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
                              for(VariationValue value in variation.variationValues!) {
                                variationText += '${variationText.endsWith('(') ? '' : ', '}${value.level}';
                              }
                              variationText += ')';
                            }
                          }else if(order.orderDetails![index].oldVariations != null && order.orderDetails![index].oldVariations!.isNotEmpty) {
                            List<String> variationTypes = order.orderDetails![index].oldVariations![0].type!.split('-');
                            if(variationTypes.length == order.orderDetails![index].productDetails!.choiceOptions!.length) {
                              int index = 0;
                              for (var choice in order.orderDetails![index].productDetails!.choiceOptions!) {
                                variationText = '$variationText${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
                                index = index + 1;
                              }
                            }else {
                              variationText = order.orderDetails![index].oldVariations![0].type ?? '';
                            }
                          }

                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomImageWidget(
                                  placeholder: Images.placeholderImage, height: 70, width: 80, fit: BoxFit.cover,
                                  image: '${splashProvider.baseUrls?.productImageUrl}/${order.orderDetails?[index].productDetails?.image}',
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                Row(children: [

                                  Expanded(child: Text(
                                    order.orderDetails![index].productDetails!.name!,
                                    style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),

                                  Text(getTranslated('amount', context)!, style: rubikRegular),

                                ]),
                                const SizedBox(height: Dimensions.fontSizeLarge),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                  Row(children: [

                                    Text('${getTranslated('quantity', context)}:',
                                        style: rubikRegular
                                    ),

                                    Text(' ${order.orderDetails![index].quantity}',
                                        style: rubikMedium.copyWith(color: Theme.of(context).primaryColor)),
                                  ]),

                                  Text(
                                    PriceConverterHelper.convertPrice(context, order.orderDetails![index].price),
                                    style: rubikMedium.copyWith(color: Theme.of(context).primaryColor),
                                  ),

                                ]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                variationText != '' ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                                  Container(height: 10, width: 10, decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  )),
                                  const SizedBox(width: Dimensions.fontSizeLarge),

                                  Expanded(child: Text(variationText,
                                    style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  )),

                                ]) :const SizedBox(),

                                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  ProductTypeWidget(productType: order.orderDetails?[index].productDetails?.productType),

                                ]) ,

                              ])),
                            ]),

                            addOns.isNotEmpty ? SizedBox(
                              height: 30,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                itemCount: addOns.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                    child: Row(children: [
                                      Text(addOns[i].name!, style: rubikRegular),
                                      const SizedBox(width: 2),
                                      Text(
                                        PriceConverterHelper.convertPrice(context, addOns[i].price),
                                        style: rubikMedium,
                                      ),
                                      const SizedBox(width: 2),
                                      Text('(${order.orderDetails![index].addOnQtys![i]})', style: rubikRegular),
                                    ]),
                                  );
                                },
                              ),
                            )
                                : const SizedBox(),
                            const Divider(height: Dimensions.paddingSizeLarge),
                          ]);
                        },
                      ),

                      (orderModel!.orderNote != null && orderModel!.orderNote!.isNotEmpty) ? Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Theme.of(context).hintColor),
                        ),
                        child: Text(orderModel!.orderNote!, style: rubikRegular.copyWith(color: Theme.of(context).hintColor)),
                      ) : const SizedBox(),

                      // Total
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('items_price', context)!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text(PriceConverterHelper.convertPrice(context, itemsPrice), style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('tax', context)!,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text('(+) ${PriceConverterHelper.convertPrice(context, tax)}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('addons', context)!,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text('(+) ${PriceConverterHelper.convertPrice(context, addOns)}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: CustomDividerWidget(),
                      ),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('subtotal', context)!,
                            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text(PriceConverterHelper.convertPrice(context, subTotal),
                            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('discount', context)!,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text('(-) ${PriceConverterHelper.convertPrice(context, discount)}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('coupon_discount', context)!,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text(
                          '(-) ${PriceConverterHelper.convertPrice(context, orderModel!.couponDiscountAmount)}',
                          style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                      ]),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('delivery_fee', context)!,
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Text('(+) ${PriceConverterHelper.convertPrice(context, deliveryCharge)}',
                            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      ]),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: CustomDividerWidget(),
                      ),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(getTranslated('total_amount', context)!,
                            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor)),
                        Text(
                          PriceConverterHelper.convertPrice(context, totalPrice),
                          style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      if(orderModel?.orderPartialPayments != null && orderModel!.orderPartialPayments!.isNotEmpty)
                        DottedBorder(
                          dashPattern: const [8, 4],
                          strokeWidth: 1.1,
                          borderType: BorderType.RRect,
                          color: Theme.of(context).colorScheme.primary,
                          radius: const Radius.circular(Dimensions.radiusDefault),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.02),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: 1),
                            child: Column(children: paymentList.map((payment) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                                Text("${getTranslated(payment.paidAmount! > 0 ? 'paid_amount' : 'due_amount', context)} (${getTranslated('${payment.paidWith}', context)})",
                                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                                  overflow: TextOverflow.ellipsis,),

                                Text( PriceConverterHelper.convertPrice(context, payment.paidAmount! > 0 ? payment.paidAmount : payment.dueAmount),
                                  style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                              ],
                              ),
                            )).toList()),
                          ),
                        ),



                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                (orderModel!.orderStatus == 'processing' || orderModel!.orderStatus == 'out_for_delivery') && orderModel?.deliveryAddress?.latitude != null
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      width: 1170,
                      child: CustomButtonWidget(
                          btnTxt: getTranslated('direction', context),
                          onTap: () {
                            Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
                              LocationHelper.openMap(
                                destinationLatitude: double.tryParse('${orderModel?.deliveryAddress?.latitude}') ?? 23.8103,
                                destinationLongitude: double.tryParse('${orderModel?.deliveryAddress?.longitude}') ?? 90.4125,
                                userLatitude: position.latitude ,
                                userLongitude: position.longitude,
                              );
                            });
                          }),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),

                orderModel?.orderStatus != 'delivered' && !(orderModel?.isGuest ?? false) ? SafeArea(child: Center(
                  child: Container(
                    width: 1170,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CustomButtonWidget(btnTxt: getTranslated('chat_with_customer', context), onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(orderModel: orderModel)));
                    }),
                  ),
                )) : const SizedBox(),

                orderModel!.orderStatus == 'done' || orderModel!.orderStatus == 'processing' ? Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.05)),
                    color: Theme.of(context).canvasColor,
                  ),
                  child: Transform.rotate(
                    angle: Provider.of<LocalizationProvider>(context).isLtr ? pi * 2 : pi, // in radians
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: SliderButtonWidget(
                        action: () {
                          LocationHelper.checkPermission(context,callBack: () {
                            Provider.of<TrackerProvider>(context, listen: false).setOrderID(orderModel!.id!);
                            Provider.of<TrackerProvider>(context, listen: false).startLocationService();
                            String token = Provider.of<AuthProvider>(context, listen: false).getUserToken();
                            Provider.of<OrderProvider>(context, listen: false)
                                .updateOrderStatus(token: token, orderId: orderModel!.id, status: 'out_for_delivery');
                            Provider.of<OrderProvider>(context, listen: false).getOrderHistoryList(1, context);
                            Navigator.pop(context);
                          });
                        },

                        ///Put label over here
                        label: Text(
                          getTranslated('swip_to_deliver_order', context)!,
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        dismissThresholds: 0.5,
                        dismissible: false,
                        icon: const Center(
                            child: Icon(
                              Icons.double_arrow_sharp,
                              color: Colors.white,
                              size: Dimensions.paddingSizeLarge,
                              semanticLabel: 'Text to announce in accessibility modes',
                            )),

                        ///Change All the color and size from here.
                        radius: 10,
                        boxShadow: const BoxShadow(blurRadius: 0.0),
                        buttonColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).canvasColor,
                        baseColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ) : orderModel?.orderStatus == 'out_for_delivery' ? Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.05)),
                  ),
                  child: Transform.rotate(
                    angle: Provider.of<LocalizationProvider>(context).isLtr ? pi * 2 : pi, // in radians
                    child: Directionality(
                      textDirection: TextDirection.ltr, // set it to rtl
                      child: SliderButtonWidget(
                        action: () {
                          String token = Provider.of<AuthProvider>(context, listen: false).getUserToken();

                          if (orderModel!.paymentStatus == 'paid') {
                            Provider.of<TrackerProvider>(context, listen: false).stopLocationService();
                            Provider.of<OrderProvider>(context, listen: false)
                                .updateOrderStatus(token: token, orderId: orderModel!.id, status: 'delivered',);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => OrderPlaceScreen(orderID: orderModel!.id.toString())));
                          } else {
                            double payableAmount = totalPrice;

                            if(orderModel!.orderPartialPayments != null && orderModel!.orderPartialPayments!.isNotEmpty){
                              payableAmount = orderModel!.orderPartialPayments?[0].dueAmount ?? 0;
                            }
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                    child: CompleteOrderDialogWidget(
                                      onTap: () {},
                                      totalPrice: payableAmount,
                                      orderModel: orderModel,
                                    ),
                                  );
                                });
                          }
                        },

                        ///Put label over here
                        label: Text(
                          getTranslated('swip_to_confirm_order', context)!,
                          style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        dismissThresholds: 0.5,
                        dismissible: false,
                        icon: const Center(
                            child: Icon(
                              Icons.double_arrow_sharp,
                              color: Colors.white,
                              size: Dimensions.paddingSizeLarge,
                              semanticLabel: 'Text to announce in accessibility modes',
                            )),

                        ///Change All the color and size from here.
                        radius: 10,
                        boxShadow: const BoxShadow(blurRadius: 0.0),
                        buttonColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).cardColor,
                        baseColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),

              ],
            )
                : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
          },
        ),
      ),
    );
  }

}
