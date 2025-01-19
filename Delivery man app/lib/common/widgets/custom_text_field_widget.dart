import 'package:flutter/material.dart';
import 'package:resturant_delivery_boy/features/language/providers/language_provider.dart';
import 'package:resturant_delivery_boy/helper/custom_extension_helper.dart';
import 'package:resturant_delivery_boy/utill/dimensions.dart';
import 'package:resturant_delivery_boy/utill/styles.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final Function? onTap;
  final String? suffixIconUrl;
  final String? prefixIconUrl;
  final bool isSearch;
  final LanguageProvider? languageProvider;
  final TextCapitalization capitalization;
  final bool showTitle;
  final String? label;
  final bool? isEnabled;



  const CustomTextFieldWidget(
      {Key? key, this.hintText = 'Write something...',
        this.controller,
        this.focusNode,
        this.nextFocus,
        this.inputType = TextInputType.text,
        this.inputAction = TextInputAction.next,
        this.maxLines = 1,
        this.fillColor,
        this.isCountryPicker = false,
        this.isShowBorder = false,
        this.isShowSuffixIcon = false,
        this.isShowPrefixIcon = false,
        this.onTap,
        this.isIcon = false,
        this.isPassword = false,
        this.suffixIconUrl,
        this.prefixIconUrl,
        this.isSearch = false,
        this.languageProvider,
        this.capitalization = TextCapitalization.none,
        this.showTitle = false,
        this.label,
        this.isEnabled = true
      }) : super(key: key);

  @override

  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      widget.showTitle ? Text(widget.hintText!, style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeSmall)) : const SizedBox(),
      SizedBox(height: widget.showTitle ? Dimensions.paddingSizeExtraSmall : 0),

      TextField(
        maxLines: widget.maxLines,
        controller: widget.controller,
        enabled: widget.isEnabled,
        focusNode: widget.focusNode,
        style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        textInputAction: widget.inputAction,
        keyboardType: widget.inputType,
        cursorColor: Theme.of(context).primaryColor,
        obscureText: widget.isPassword ? _obscureText : false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 1, color: context.theme.hintColor.withOpacity(0.1)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 1, color: context.theme.primaryColor),
          ),
          
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(width: 1, color: context.theme.hintColor.withOpacity(0.3)),
          ),
          isDense: true,
          hintText: widget.hintText,
          fillColor: widget.fillColor ?? Theme.of(context).cardColor,
          hintStyle: rubikRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor.withOpacity(0.6),
          ),


          filled: true,
          prefixIcon: widget.isShowPrefixIcon
              ? Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeSmall),
            child: Image.asset(widget.prefixIconUrl!, height: 20, width: 20,),
          )
              : const SizedBox.shrink(),
          prefixIconConstraints: const BoxConstraints(minWidth: 23, maxHeight: 20),
          suffixIcon: widget.isShowSuffixIcon
              ? widget.isPassword
              ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).hintColor.withOpacity(.3)),
              onPressed: _toggle)
              : widget.isIcon
              ? Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeSmall),
            child: Image.asset(
              widget.suffixIconUrl!,
              width: 15,
              height: 15,
            ),
          )
              : null
              : null,
        ),

        onTap: widget.onTap as void Function()?,
        onSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
      ),
    ]);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
