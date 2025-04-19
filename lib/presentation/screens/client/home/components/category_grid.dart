import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      {
        'name': 'Automercados',
        'icon': Icons.shopping_cart_outlined,
        'gradient': [
          const Color(0xFFFF9A9E),
          const Color(0xFFFAD0C4),
        ],
      },
      {
        'name': 'Charcuterías',
        'icon': Icons.lunch_dining_outlined,
        'gradient': [
          const Color(0xFF96E6A1),
          const Color(0xFFD4FC79),
        ],
      },
      {
        'name': 'Comida\nPreparada',
        'icon': Icons.restaurant_outlined,
        'gradient': [
          const Color(0xFFFF9A9E),
          const Color(0xFFFECFEF),
        ],
      },
      {
        'name': 'Panaderías',
        'icon': Icons.bakery_dining_outlined,
        'gradient': [
          const Color(0xFFFAD961),
          const Color(0xFFF76B1C),
        ],
      },
      {
        'name': 'Bebidas',
        'icon': Icons.local_drink_outlined,
        'gradient': [
          const Color(0xFF84FAB0),
          const Color(0xFF8FD3F4),
        ],
      },
      {
        'name': 'Snacks',
        'icon': Icons.cookie_outlined,
        'gradient': [
          const Color(0xFFE0C3FC),
          const Color(0xFF8EC5FC),
        ],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            // TODO: Implementar navegación a categoría
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        (category['gradient'] as List<Color>)[0]
                            .withOpacity(0.3),
                        (category['gradient'] as List<Color>)[1]
                            .withOpacity(0.2),
                      ]
                    : category['gradient'] as List<Color>,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : (category['gradient'] as List<Color>)[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: isDark ? Colors.white : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 