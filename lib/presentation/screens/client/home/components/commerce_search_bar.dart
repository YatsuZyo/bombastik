import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/presentation/providers/client-providers/home/home_provider.dart';

class CommerceSearchBar extends ConsumerStatefulWidget {
  const CommerceSearchBar({super.key});

  @override
  ConsumerState<CommerceSearchBar> createState() => _CommerceSearchBarState();
}

class _CommerceSearchBarState extends ConsumerState<CommerceSearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceVariant
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (value) {
              ref.read(homeProvider.notifier).setSearchQuery(value);
            },
            onTap: () {
              setState(() {
                _isSearching = true;
              });
            },
            onSubmitted: (_) {
              setState(() {
                _isSearching = false;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar comercios...',
              hintStyle: GoogleFonts.poppins(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(homeProvider.notifier).setSearchQuery('');
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (_isSearching) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCategoryFilter(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLocationFilter(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(homeProvider).selectedCategory;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          hint: Text(
            'Categoría',
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Todas'),
            ),
            DropdownMenuItem(
              value: 'restaurante',
              child: Text('Restaurantes'),
            ),
            DropdownMenuItem(
              value: 'tienda',
              child: Text('Tiendas'),
            ),
            DropdownMenuItem(
              value: 'cafeteria',
              child: Text('Cafeterías'),
            ),
          ],
          onChanged: (value) {
            ref.read(homeProvider.notifier).setSelectedCategory(value);
          },
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface,
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    final theme = Theme.of(context);
    final selectedLocation = ref.watch(homeProvider).selectedLocation;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLocation,
          hint: Text(
            'Ubicación',
            style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: null,
              child: Text('Todas'),
            ),
            DropdownMenuItem(
              value: 'centro',
              child: Text('Centro'),
            ),
            DropdownMenuItem(
              value: 'norte',
              child: Text('Norte'),
            ),
            DropdownMenuItem(
              value: 'sur',
              child: Text('Sur'),
            ),
          ],
          onChanged: (value) {
            ref.read(homeProvider.notifier).setSelectedLocation(value);
          },
          style: GoogleFonts.poppins(
            color: theme.colorScheme.onSurface,
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
} 