import 'package:flutter/material.dart';
import 'package:bombastik/config/themes/app_theme.dart';

class GradientSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final bool isDarkMode;
  final PreferredSizeWidget? bottom;
  final bool floating;
  final bool pinned;

  const GradientSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = false,
    this.leading,
    required this.isDarkMode,
    this.bottom,
    this.floating = true,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      bottom: bottom,
      floating: floating,
      pinned: pinned,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.statsGradientDarkStart, AppColors.statsGradientDarkEnd]
                : [AppColors.statsGradientStart, AppColors.statsGradientEnd],
          ),
        ),
      ),
    );
  }
} 