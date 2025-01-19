import 'package:flutter/material.dart';
import 'package:flutter_restaurant/features/address/domain/models/prediction_model.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';

class SearchItemWidget extends StatelessWidget {
  final PredictionModel? suggestion;
  const SearchItemWidget({
    super.key, this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(children: [
        const Icon(Icons.location_on),

        Expanded(child: Text(
          suggestion?.description ?? getTranslated('no_address_found', context)!, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge,
          ),
        )),
      ]),
    );
  }
}