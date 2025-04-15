import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/presentation/providers/commerce-providers/promotions/promotions_provider.dart';
import 'package:bombastik/presentation/screens/commerce/promotions/promotion_form_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bombastik/presentation/widgets/gradient_app_bar.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/widgets/gradient_card.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final promotionsAsync = ref.watch(promotionsStreamProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Mis Promociones',
        isDarkMode: isDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPromotionDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(promotionsStreamProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<PromotionStatus?>(
                  value: _selectedStatus,
                  hint: Text(
                    'Filtrar por estado',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.primary,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.all_inclusive,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Todas',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...PromotionStatus.values.map((status) {
                      Color statusColor;
                      IconData statusIcon;
                      switch (status) {
                        case PromotionStatus.active:
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                          break;
                        case PromotionStatus.scheduled:
                          statusColor = Colors.blue;
                          statusIcon = Icons.schedule;
                          break;
                        case PromotionStatus.expired:
                          statusColor = Colors.grey;
                          statusIcon = Icons.timer_off;
                          break;
                        case PromotionStatus.cancelled:
                          statusColor = Colors.red;
                          statusIcon = Icons.cancel;
                          break;
                      }
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                statusIcon,
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getStatusText(status),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
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
            ),
            Expanded(
              child: promotionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error al cargar las promociones',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              ref.invalidate(promotionsStreamProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                data: (promotions) {
                  debugPrint('=== PROMOCIONES RECIBIDAS ===');
                  debugPrint('Cantidad de promociones: ${promotions.length}');
                  debugPrint(
                    'Promociones: ${promotions.map((p) => p.title).join(', ')}',
                  );

                  if (promotions.isEmpty) {
                    debugPrint('No hay promociones para mostrar');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay promociones registradas',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showAddPromotionDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear Promoción'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredPromotions =
                      _selectedStatus != null
                          ? promotions
                              .where((p) => p.status == _selectedStatus)
                              .toList()
                          : promotions;

                  debugPrint('=== PROMOCIONES FILTRADAS ===');
                  debugPrint('Estado seleccionado: $_selectedStatus');
                  debugPrint(
                    'Cantidad de promociones filtradas: ${filteredPromotions.length}',
                  );
                  debugPrint(
                    'Promociones filtradas: ${filteredPromotions.map((p) => p.title).join(', ')}',
                  );

                  return ListView.builder(
                    itemCount: filteredPromotions.length,
                    itemBuilder: (context, index) {
                      final promotion = filteredPromotions[index];
                      debugPrint('=== CONSTRUYENDO TARJETA ===');
                      debugPrint('Título: ${promotion.title}');
                      debugPrint('Estado: ${promotion.status}');
                      debugPrint('Fecha inicio: ${promotion.startDate}');
                      debugPrint('Fecha fin: ${promotion.endDate}');
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _PromotionCard(promotion: promotion),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

class _PromotionCard extends ConsumerStatefulWidget {
  final Promotion promotion;

  const _PromotionCard({required this.promotion});

  @override
  ConsumerState<_PromotionCard> createState() => _PromotionCardState();
}

class _PromotionCardState extends ConsumerState<_PromotionCard> {
  @override
  Widget build(BuildContext context) {
    debugPrint('=== CONSTRUYENDO TARJETA DE PROMOCIÓN ===');
    debugPrint('Título: ${widget.promotion.title}');
    debugPrint('Descripción: ${widget.promotion.description}');
    debugPrint('Tipo: ${widget.promotion.type}');
    debugPrint('Estado: ${widget.promotion.status}');
    debugPrint('Valor: ${widget.promotion.value}');
    debugPrint('Fecha inicio: ${widget.promotion.startDate}');
    debugPrint('Fecha fin: ${widget.promotion.endDate}');
    debugPrint('Productos: ${widget.promotion.productIds.join(', ')}');
    debugPrint('Categoría: ${widget.promotion.categoryId}');
    debugPrint('Código: ${widget.promotion.code}');

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final isActive =
        widget.promotion.status == PromotionStatus.active &&
        widget.promotion.startDate.isBefore(now) &&
        widget.promotion.endDate.isAfter(now);

    debugPrint('¿Está activa?: $isActive');
    debugPrint('Fecha actual: $now');

    return GradientCard(
      isDarkMode: isDark,
      customGradient:
          isDark
              ? [
                AppColors.promotionsDarkGradientStart,
                AppColors.promotionsDarkGradientEnd,
              ]
              : [
                AppColors.promotionsGradientStart,
                AppColors.promotionsGradientEnd,
              ],
      customTitleColor: AppColors.promotionCardTitle,
      customTextColor: AppColors.promotionCardText,
      customIconColor: AppColors.promotionCardIcon,
      builder:
          (iconColor, titleColor, textColor) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.promotion.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    widget.promotion.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.promotion.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.promotion.description,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildStatusChip(theme, iconColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDiscountSection(theme, titleColor, textColor),
                    const SizedBox(height: 16),
                    _buildPromotionDetails(theme, titleColor, textColor),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _showEditDialog(context),
                          icon: const Icon(Icons.edit),
                          label: Text(
                            'Editar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () => _showDeleteDialog(context, ref),
                          icon: const Icon(Icons.delete),
                          label: Text(
                            'Eliminar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.3),
                          ),
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

  Widget _buildStatusChip(ThemeData theme, Color iconColor) {
    Color chipColor;
    IconData statusIcon;
    String statusText;

    switch (widget.promotion.status) {
      case PromotionStatus.active:
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Activa';
        break;
      case PromotionStatus.scheduled:
        chipColor = Colors.blue;
        statusIcon = Icons.schedule;
        statusText = 'Programada';
        break;
      case PromotionStatus.expired:
        chipColor = Colors.grey;
        statusIcon = Icons.timer_off;
        statusText = 'Expirada';
        break;
      case PromotionStatus.cancelled:
        chipColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: chipColor, size: 16),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              color: chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection(
    ThemeData theme,
    Color titleColor,
    Color textColor,
  ) {
    String discountText;
    IconData discountIcon;

    switch (widget.promotion.type) {
      case PromotionType.percentage:
        discountText = '${widget.promotion.value.toStringAsFixed(0)}%';
        discountIcon = Icons.percent;
        break;
      case PromotionType.fixedAmount:
        discountText = '\$${widget.promotion.value.toStringAsFixed(2)}';
        discountIcon = Icons.attach_money;
        break;
      case PromotionType.buyXGetY:
        discountText = '${widget.promotion.value.toInt()}+1';
        discountIcon = Icons.card_giftcard;
        break;
      case PromotionType.bundle:
        discountText = 'COMBO';
        discountIcon = Icons.shopping_bag;
        break;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(discountIcon, color: titleColor, size: 32),
              const SizedBox(width: 12),
              Text(
                'DESCUENTO',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                discountText,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: titleColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CÓDIGO',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        widget.promotion.code ?? 'Sin código',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  final code = widget.promotion.code;
                  if (code != null) {
                    Clipboard.setData(ClipboardData(text: code));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Código copiado al portapapeles',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: Icon(Icons.copy_rounded, color: titleColor, size: 20),
                tooltip: 'Copiar código',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionDetails(
    ThemeData theme,
    Color titleColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: titleColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Válido del ${_formatDate(widget.promotion.startDate)} al ${_formatDate(widget.promotion.endDate)}',
                style: GoogleFonts.poppins(fontSize: 14, color: textColor),
              ),
            ),
          ],
        ),
        if (widget.promotion.minPurchaseAmount != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.shopping_cart, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mínimo de compra: \$${widget.promotion.minPurchaseAmount!.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 14, color: textColor),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person_outline, color: titleColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Límite: 1 uso por cliente',
              style: GoogleFonts.poppins(fontSize: 14, color: textColor),
            ),
          ],
        ),
        if (widget.promotion.maxUses != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group_outlined, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Usos totales restantes: ${widget.promotion.maxUses! - (widget.promotion.usedCount ?? 0)}',
                style: GoogleFonts.poppins(fontSize: 14, color: textColor),
              ),
            ],
          ),
        ],
        if (widget.promotion.categoryId != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, color: titleColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Categoría: ${widget.promotion.categoryId!.toUpperCase()}',
                style: GoogleFonts.poppins(fontSize: 14, color: textColor),
              ),
            ],
          ),
        ],
        if (widget.promotion.code != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                color: titleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Código: ${widget.promotion.code}',
                  style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                color: titleColor,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: widget.promotion.code!),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Código copiado al portapapeles',
                          style: GoogleFonts.poppins(),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PromotionFormDialog(promotion: widget.promotion),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Eliminar Promoción',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar la promoción "${widget.promotion.title}"? Esta acción no se puede deshacer.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancelar', style: GoogleFonts.poppins()),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(promotionRepositoryProvider)
                        .deletePromotion(widget.promotion.id!);
                    if (!mounted) return;

                    // Cerrar el diálogo
                    Navigator.pop(dialogContext);

                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Promoción eliminada exitosamente',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    // Cerrar el diálogo
                    Navigator.pop(dialogContext);

                    // Mostrar mensaje de error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error al eliminar la promoción: $e',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
