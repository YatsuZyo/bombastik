// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/presentation/providers/client-providers/home/home_provider.dart';
import 'package:bombastik/presentation/screens/client/home/components/commerce_search_bar.dart';
import 'package:bombastik/presentation/screens/client/home/components/commerce_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 100 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton(
          onPressed: _scrollToTop,
          backgroundColor: theme.colorScheme.primary,
          child: Icon(
            Icons.arrow_upward_rounded,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header con ubicación y búsqueda
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [const Color(0xFF568028), const Color(0xFF2A7654)]
                            : [
                              const Color(0xFF86C144),
                              const Color(0xFF42B883),
                            ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación Actual',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Todos',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showFilterModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                ref
                                    .read(homeProvider.notifier)
                                    .setSearchQuery(value);
                              },
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Encuentra tus lugares favoritos',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.2,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista de comercios
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (homeState.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (homeState.errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            homeState.errorMessage!,
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (homeState.searchQuery != null &&
                              homeState.searchQuery!.isNotEmpty) ...[
                            Text(
                              'Resultados de búsqueda',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          const CommerceList(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtros',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(homeProvider.notifier)
                                ..setSelectedCategory(null)
                                ..setSelectedLocation(null);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Limpiar',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Categoría',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final selectedCategory =
                              ref.watch(homeProvider).selectedCategory;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: 'Todas',
                                isSelected: selectedCategory == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                        .read(homeProvider.notifier)
                                        .setSelectedCategory(null);
                                  }
                                },
                              ),
                              _FilterChip(
                                label: 'Restaurantes',
                                isSelected: selectedCategory == 'restaurante',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedCategory(
                                        selected ? 'restaurante' : null,
                                      );
                                },
                              ),
                              _FilterChip(
                                label: 'Tiendas',
                                isSelected: selectedCategory == 'tienda',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedCategory(
                                        selected ? 'tienda' : null,
                                      );
                                },
                              ),
                              _FilterChip(
                                label: 'Cafeterías',
                                isSelected: selectedCategory == 'cafeteria',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedCategory(
                                        selected ? 'cafeteria' : null,
                                      );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ubicación',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final selectedLocation =
                              ref.watch(homeProvider).selectedLocation;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: 'Todas',
                                isSelected: selectedLocation == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                        .read(homeProvider.notifier)
                                        .setSelectedLocation(null);
                                  }
                                },
                              ),
                              _FilterChip(
                                label: 'Centro',
                                isSelected: selectedLocation == 'centro',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedLocation(
                                        selected ? 'centro' : null,
                                      );
                                },
                              ),
                              _FilterChip(
                                label: 'Norte',
                                isSelected: selectedLocation == 'norte',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedLocation(
                                        selected ? 'norte' : null,
                                      );
                                },
                              ),
                              _FilterChip(
                                label: 'Sur',
                                isSelected: selectedLocation == 'sur',
                                onSelected: (selected) {
                                  ref
                                      .read(homeProvider.notifier)
                                      .setSelectedLocation(
                                        selected ? 'sur' : null,
                                      );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Aplicar Filtros',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
