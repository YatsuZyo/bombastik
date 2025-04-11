import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/presentation/providers/commerce-providers/promotions/promotions_provider.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class PromotionFormDialog extends ConsumerStatefulWidget {
  final Promotion? promotion;

  const PromotionFormDialog({super.key, this.promotion});

  @override
  ConsumerState<PromotionFormDialog> createState() =>
      _PromotionFormDialogState();
}

class _PromotionFormDialogState extends ConsumerState<PromotionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxUsesController = TextEditingController();
  final _discountController = TextEditingController();
  final _codeController = TextEditingController();

  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _selectedProductIds = [];
  ProductCategory? _selectedCategory;
  String? _imageUrl;
  bool _isCategoryPromotion = false;

  // Mapa de iconos para categorías
  final Map<ProductCategory, IconData> categoryIcons = {
    ProductCategory.frutas: Icons.apple,
    ProductCategory.verduras: Icons.eco,
    ProductCategory.carnes: Icons.restaurant_menu,
    ProductCategory.lacteos: Icons.egg,
    ProductCategory.panaderia: Icons.bakery_dining,
    ProductCategory.bebidas: Icons.local_drink,
    ProductCategory.snacks: Icons.cookie,
    ProductCategory.limpieza: Icons.cleaning_services,
    ProductCategory.otros: Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    // Asegurarnos de que el commerceId esté establecido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commerceId = ref.read(currentCommerceIdProvider);
      if (commerceId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró el ID del comercio'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _initializeForm() {
    final promotion = widget.promotion;
    if (promotion != null) {
      _titleController.text = promotion.title;
      _descriptionController.text = promotion.description;
      _discountController.text = promotion.value.toString();
      _startDate = promotion.startDate;
      _endDate = promotion.endDate;
      _selectedProductIds = List.from(promotion.productIds ?? []);
      _selectedCategory =
          promotion.categoryId != null
              ? ProductCategory.values.firstWhere(
                (e) => e.toString().split('.').last == promotion.categoryId,
                orElse: () => ProductCategory.otros,
              )
              : null;
      _isCategoryPromotion = promotion.categoryId != null;
      _imageUrl = promotion.imageUrl;
      if (promotion.minPurchaseAmount != null) {
        _minPurchaseController.text = promotion.minPurchaseAmount.toString();
      }
      if (promotion.maxUses != null) {
        _maxUsesController.text = promotion.maxUses.toString();
      }
      if (promotion.code != null) {
        _codeController.text = promotion.code!;
      }
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _selectedProductIds = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minPurchaseController.dispose();
    _maxUsesController.dispose();
    _discountController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Row(
        children: [
          Icon(
            widget.promotion == null ? Icons.local_offer : Icons.edit,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.promotion == null ? 'Nueva Promoción' : 'Editar Promoción',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Título',
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: Icons.title,
                  hint: 'Ingrese el título de la promoción',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Descripción',
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: Icons.description,
                  hint: 'Ingrese la descripción de la promoción',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Código Promocional',
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  prefixIcon: Icons.code,
                  hint: 'Ej: PROMO20',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El código es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Valor del Descuento',
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent,
                  hint: 'Ej: 20',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El descuento es requerido';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Ingrese un número válido';
                    }
                    if (number < 0 || number > 100) {
                      return 'El descuento debe estar entre 0 y 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Inicio',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(_startDate),
                                      style: GoogleFonts.poppins(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Fin',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(_endDate),
                                      style: GoogleFonts.poppins(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Promoción por Categoría',
                    style: GoogleFonts.poppins(),
                  ),
                  value: _isCategoryPromotion,
                  onChanged: (value) {
                    setState(() {
                      _isCategoryPromotion = value;
                      if (value) {
                        _selectedProductIds = [];
                      }
                    });
                  },
                ),
                if (!_isCategoryPromotion) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Productos Aplicables',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ref
                      .watch(productsStreamProvider)
                      .when(
                        data: (products) {
                          if (products.isEmpty) {
                            return const Center(
                              child: Text('No hay productos disponibles'),
                            );
                          }
                          final validProducts =
                              products
                                  .where((product) => product.id != null)
                                  .toList();
                          if (validProducts.isEmpty) {
                            return const Center(
                              child: Text(
                                'No hay productos válidos disponibles',
                              ),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                validProducts.map((product) {
                                  final isSelected = _selectedProductIds
                                      .contains(product.id);
                                  return FilterChip(
                                    label: Text(product.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedProductIds.add(product.id!);
                                        } else {
                                          _selectedProductIds.remove(
                                            product.id,
                                          );
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (_, __) => const Center(
                              child: Text('Error al cargar productos'),
                            ),
                      ),
                ] else ...[
                  const SizedBox(height: 16),
                  Text(
                    'Categoría',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductCategory>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary,
                        ),
                        items:
                            ProductCategory.values.map((category) {
                              final name = category.toString().split('.').last;
                              final capitalizedName =
                                  name[0].toUpperCase() + name.substring(1);
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        categoryIcons[category] ??
                                            Icons.category,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      capitalizedName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _minPurchaseController,
                  label: 'Monto Mínimo de Compra (opcional)',
                  keyboardType: TextInputType.number,
                  hint: 'Ej: 100.00',
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingresa un número válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _maxUsesController,
                  label: 'Máximo de Usos (opcional)',
                  keyboardType: TextInputType.number,
                  hint: 'Ej: 50',
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Por favor ingresa un número válido';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: GoogleFonts.poppins(color: theme.colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: _savePromotion,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'Guardar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: isStart ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final commerceId = ref.read(currentCommerceIdProvider);
      if (commerceId == null) throw Exception('ID de comercio no válido');

      // Validar que al menos se haya seleccionado una categoría o productos
      if (!_isCategoryPromotion && _selectedProductIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes seleccionar al menos un producto'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_isCategoryPromotion && _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes seleccionar una categoría'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final promotion = Promotion(
        id: widget.promotion?.id,
        commerceId: commerceId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: widget.promotion?.type ?? PromotionType.percentage,
        status: widget.promotion?.status ?? PromotionStatus.active,
        value: double.parse(_discountController.text),
        startDate: _startDate,
        endDate: _endDate,
        productIds: _isCategoryPromotion ? [] : _selectedProductIds,
        categoryId:
            _isCategoryPromotion && _selectedCategory != null
                ? _selectedCategory.toString().split('.').last
                : null,
        minPurchaseAmount:
            _minPurchaseController.text.isNotEmpty
                ? double.parse(_minPurchaseController.text)
                : null,
        maxUses:
            _maxUsesController.text.isNotEmpty
                ? int.parse(_maxUsesController.text)
                : null,
        code:
            _codeController.text.trim().isNotEmpty
                ? _codeController.text.trim()
                : null,
        imageUrl: _imageUrl,
        usedCount: widget.promotion?.usedCount ?? 0,
      );

      if (widget.promotion == null) {
        await ref.read(promotionRepositoryProvider).createPromotion(promotion);
      } else {
        await ref.read(promotionRepositoryProvider).updatePromotion(promotion);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la promoción: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
