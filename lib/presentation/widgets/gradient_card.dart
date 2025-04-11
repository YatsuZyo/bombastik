import 'package:flutter/material.dart';
import 'package:bombastik/config/themes/app_theme.dart';

class GradientCard extends StatelessWidget {
  final Widget Function(Color iconColor, Color titleColor, Color textColor)
  builder;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final List<Color>? customGradient;
  final Color? customIconColor;
  final Color? customTitleColor;
  final Color? customTextColor;

  const GradientCard({
    super.key,
    required this.builder,
    this.padding,
    this.onTap,
    required this.isDarkMode,
    this.customGradient,
    this.customIconColor,
    this.customTitleColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        customIconColor ??
        (isDarkMode ? AppColors.darkCardIcon : AppColors.lightCardIcon);
    final titleColor =
        customTitleColor ??
        (isDarkMode ? AppColors.darkCardTitle : AppColors.lightCardTitle);
    final textColor =
        customTextColor ??
        (isDarkMode ? AppColors.darkCardText : AppColors.lightCardText);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  customGradient ??
                  (isDarkMode
                      ? [AppColors.darkSurface, AppColors.darkBackground]
                      : [
                        AppColors.lightPrimary,
                        AppColors.lightPrimaryVariant,
                      ]),
            ),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: builder(iconColor, titleColor, textColor),
        ),
      ),
    );
  }
}
