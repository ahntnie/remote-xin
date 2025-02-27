import 'package:flutter/material.dart';

import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';

class NumPadWidget extends StatelessWidget {
  const NumPadWidget({
    required this.onTap,
    required this.onTapCall,
    Key? key,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.clearIcon,
    this.themeColor,
    this.textStyle,
    this.backgroundColor,
    this.iconSize,
  }) : super(key: key);

  // TRIGGERED ON EACH BUTTON TAB, RETURNS THE BUTTON CLICKED INT OR 99 IF CLEAR BUTTON
  final ValueChanged<String> onTap;
  final ValueChanged onTapCall;

  // VALUE FOR MAIN AXIS SPACING OF NUMPAD
  final double? mainAxisSpacing;

  // VALUE FOR CROSS AXIS SPACING OF NUMPAD
  final double? crossAxisSpacing;

  // OPTIONAL ICON FOR CLEAR BUTTON
  final Icon? clearIcon;

  // COLOR FOR THE WHOLE WIDGET THEME
  final Color? themeColor;

  // STYLE FOR THE TEXT ON THE NUMBER ITEM
  final TextStyle? textStyle;

  // COLOR FOR NUMPAD WIDGET BACKGROUND COLOR
  final Color? backgroundColor;

  // VALUE FOR NUMBER TEXT SIZE - WON'T WORK IF YOU PROVIDE clearIcon
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    /****************************
     * DEFAULT VALUES
     ****************************/
    final size = MediaQuery.of(context).size;
    const values = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    const valuesText = [
      '',
      'ABC',
      'DEF',
      'GHI',
      'JKL',
      'MNO',
      'PQRS',
      'TUV',
      'WXYZ'
    ];
    final mSpacing = size.width * 0.06;
    final cSpacing = size.height * 0.06;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      color: backgroundColor ?? Colors.white,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: mainAxisSpacing ?? mSpacing,
        crossAxisSpacing: crossAxisSpacing ?? cSpacing,
        crossAxisCount: 3,
        children: [
          ...List.generate(
            values.length,
            (index) => numItem(
              value: values[index].toString(),
              valueText: valuesText[index],
              onTap: onTap,
            ),
          ),

          // hàng 4
          numItem(
            value: '*',
            onTap: onTap,
            widget: AppIcon(
              icon: AppIcons.asterisk,
              size: Sizes.s20,
            ),
          ),
          numItem(value: '0', valueText: '', onTap: onTap),
          numItem(
            value: '#',
            onTap: onTap,
            widget: AppIcon(
              icon: AppIcons.number,
              size: Sizes.s20,
            ),
          ),

          // hàng 5
          const SizedBox(),
          numItem(
            value: 'call',
            onTap: onTapCall,
            colorButton: const Color(0xff32D12F),
            isShowShadow: false,
            widget: AppIcon(
              icon: AppIcons.callFill,
              size: Sizes.s36,
            ),
          ),
          // THE CLEAR OR DELETE BUTTON
          numItem(
            value: 'delete',
            onTap: onTap,
            widget: Icon(
              Icons.backspace_outlined,
              size: iconSize ?? 30,
              color: Colors.white,
            ),
            boxDecoration: const BoxDecoration(),
          ),
        ],
      ),
    );
  }

  Widget numItem({
    required Function onTap,
    String? value,
    String? valueText,
    Widget? widget,
    Color? colorButton,
    BoxDecoration? boxDecoration,
    bool isShowShadow = true,
  }) {
    const buttonSize = 40.0;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: boxDecoration ??
            BoxDecoration(
              color: colorButton ?? AppColors.opacityBackground,
              shape: BoxShape.circle,
              boxShadow: isShowShadow
                  ? const [
                      BoxShadow(
                        blurRadius: 1,
                        offset: Offset(0, -2),
                        color: Colors.white,
                      ),
                      BoxShadow(
                        // offset: Offset(0, 2),
                        color: AppColors.label45,
                      ),
                    ]
                  : null,
            ),
        child: Center(
          child: widget ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value',
                    style: AppTextStyles.s28w500,
                  ),
                  (valueText ?? '').isNotEmpty
                      ? Text(
                          '$valueText',
                          style: AppTextStyles.s12w500,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
        ),
      ),
    );
  }
}
