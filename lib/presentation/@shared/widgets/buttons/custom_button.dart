import 'package:slims/core/constants/colors.dart';
import 'package:flutter/material.dart';

import '../text/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final bool enabled;
  final EdgeInsets? padding;
  final double borderRadius;
  final double? height;
  final bool loading;

  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.width = double.infinity,
    this.backgroundColor = MasterColor.primary,
    this.textColor = MasterColor.onPrimary,
    this.fontSize = 16.0,
    this.enabled = true,
    this.loading = false,
    this.padding,
    this.child,
    this.height,
    this.borderRadius = 8.0,
  });

  const CustomButton.positive({
    super.key,
    this.text,
    this.onPressed,
    this.width,
    this.backgroundColor = MasterColor.success,
    this.textColor = MasterColor.onSuccess,
    this.fontSize = 14.0,
    this.enabled = true,
    this.loading = false,
    this.padding,
    this.child,
    this.height,
    this.borderRadius = 8.0,
  });

  const CustomButton.negative({
    super.key,
    this.text,
    this.onPressed,
    this.width,
    this.backgroundColor = MasterColor.danger,
    this.textColor = MasterColor.onDanger,
    this.fontSize = 14.0,
    this.enabled = true,
    this.loading = false,
    this.padding,
    this.child,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled || !loading ? onPressed : null,
      splashColor: MasterColor.transparent,
      highlightColor: MasterColor.transparent,
      child: IntrinsicWidth(
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled
                ? backgroundColor
                : MasterColor.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: enabled ? backgroundColor : MasterColor.dark_20,
            ),
          ),
          child: !loading
              ? child ??
                    CustomText(
                      text ?? '',
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    )
              : CustomText(
                  'Loading...',
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
        ),
      ),
    );
  }
}
