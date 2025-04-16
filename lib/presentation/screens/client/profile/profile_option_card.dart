import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/config/themes/app_theme.dart';

class ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const ProfileOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [
                    const Color(0xFF568028),  // Verde oscuro principal
                    const Color(0xFF2A7654),  // Verde oscuro secundario
                  ]
                : [
                    const Color(0xFF86C144),  // Verde principal
                    const Color(0xFF42B883),  // Verde secundario
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? const Color(0xFF86C144).withOpacity(0.1)
                : const Color(0xFF42B883).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? const Color(0xFF568028).withOpacity(0.3)
                  : const Color(0xFF86C144).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor ?? Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 