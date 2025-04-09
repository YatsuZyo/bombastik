import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/presentation/providers/commerce-providers/promotions/promotions_provider.dart';
import 'package:bombastik/presentation/screens/commerce/promotions/promotion_form_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  PromotionStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        ref.read(currentCommerceIdProvider.notifier).state = user.uid;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promotionsAsync = ref.watch(promotionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Promociones'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPromotionDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por estado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<PromotionStatus?>(
              value: _selectedStatus,
              hint: const Text('Filtrar por estado'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...PromotionStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }),
              ],
              onChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),
          ),
          // Lista de promociones
          Expanded(
            child: promotionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(child: Text('Error: $error')),
              data: (promotions) {
                if (promotions.isEmpty) {
                  return const Center(
                    child: Text('No hay promociones registradas'),
                  );
                }

                // Filtrar por estado si está seleccionado
                final filteredPromotions =
                    _selectedStatus != null
                        ? promotions
                            .where((p) => p.status == _selectedStatus)
                            .toList()
                        : promotions;

                return ListView.builder(
                  itemCount: filteredPromotions.length,
                  itemBuilder: (context, index) {
                    final promotion = filteredPromotions[index];
                    return _PromotionCard(promotion: promotion);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PromotionFormDialog(),
    );
  }

  String _getStatusText(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.active:
        return 'Activa';
      case PromotionStatus.scheduled:
        return 'Programada';
      case PromotionStatus.expired:
        return 'Expirada';
      case PromotionStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class _PromotionCard extends ConsumerWidget {
  final Promotion promotion;

  const _PromotionCard({required this.promotion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isActive =
        promotion.status == PromotionStatus.active &&
        promotion.startDate.isBefore(now) &&
        promotion.endDate.isAfter(now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la promoción si existe
          if (promotion.imageUrl != null)
            Image.network(
              promotion.imageUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
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
                        promotion.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    _buildStatusChip(theme),
                  ],
                ),
                const SizedBox(height: 8),
                Text(promotion.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 8),
                _buildPromotionDetails(theme),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isActive)
                      TextButton(
                        onPressed: () => _showCancelDialog(context, ref),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _showEditDialog(context),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color chipColor;
    String statusText;

    switch (promotion.status) {
      case PromotionStatus.active:
        chipColor = Colors.green;
        statusText = 'Activa';
        break;
      case PromotionStatus.scheduled:
        chipColor = Colors.blue;
        statusText = 'Programada';
        break;
      case PromotionStatus.expired:
        chipColor = Colors.grey;
        statusText = 'Expirada';
        break;
      case PromotionStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelada';
        break;
    }

    return Chip(
      label: Text(statusText),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(color: chipColor),
    );
  }

  Widget _buildPromotionDetails(ThemeData theme) {
    String valueText;
    switch (promotion.type) {
      case PromotionType.percentage:
        valueText = '${promotion.value}% de descuento';
        break;
      case PromotionType.fixedAmount:
        valueText = '${promotion.value} \$ de descuento';
        break;
      case PromotionType.buyXGetY:
        valueText = 'Compra ${promotion.value.toInt()} y llévate más';
        break;
      case PromotionType.bundle:
        valueText = 'Combo especial';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          valueText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Válido del ${_formatDate(promotion.startDate)} al ${_formatDate(promotion.endDate)}',
          style: theme.textTheme.bodyMedium,
        ),
        if (promotion.minPurchaseAmount != null)
          Text(
            'Mínimo de compra: ${promotion.minPurchaseAmount}\$.',
            style: theme.textTheme.bodyMedium,
          ),
        if (promotion.maxUses != null)
          Text(
            'Usos restantes: ${promotion.maxUses! - (promotion.usedCount ?? 0)}',
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PromotionFormDialog(promotion: promotion),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Promoción'),
            content: Text(
              '¿Estás seguro de cancelar la promoción "${promotion.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(promotionRepositoryProvider)
                      .updatePromotionStatus(
                        promotion.id!,
                        PromotionStatus.cancelled,
                      );
                  Navigator.pop(context);
                },
                child: const Text('Sí, Cancelar'),
              ),
            ],
          ),
    );
  }
}
