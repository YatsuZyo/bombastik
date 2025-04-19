import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/domain/models/commerce.dart';
import 'package:bombastik/presentation/providers/client-providers/home/commerce_provider.dart';

class CommerceList extends ConsumerWidget {
  const CommerceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commercesAsync = ref.watch(commercesProvider);

    return commercesAsync.when(
      data: (commerces) {
        if (commerces.isEmpty) {
          return Center(
            child: Text(
              'No hay comercios disponibles',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commerces.length,
          itemBuilder: (context, index) {
            final commerce = commerces[index];
            return _CommerceCard(commerce: commerce);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error al cargar los comercios',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _CommerceCard extends StatelessWidget {
  final Commerce commerce;

  const _CommerceCard({required this.commerce});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navegar al detalle del comercio
          // Navigator.pushNamed(context, '/commerce-detail', arguments: commerce.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                commerce.imageUrl ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.store,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          commerce.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: commerce.isOpen
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          commerce.isOpen ? 'Abierto' : 'Cerrado',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: commerce.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    commerce.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        commerce.location,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        commerce.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${commerce.totalRatings})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 