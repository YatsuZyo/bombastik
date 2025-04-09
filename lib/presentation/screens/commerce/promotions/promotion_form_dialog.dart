import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/promotion.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/presentation/providers/commerce-providers/promotions/promotions_provider.dart';
import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:bombastik/infrastructure/services/imgbb_service.dart';
import 'package:bombastik/config/api_keys.dart';

class PromotionFormDialog extends ConsumerStatefulWidget {
  final Promotion? promotion;

  const PromotionFormDialog({
    super.key,
    this.promotion,
  });

  @override
  ConsumerState<PromotionFormDialog> createState() => _PromotionFormDialogState();
}

class _PromotionFormDialogState extends ConsumerState<PromotionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxUsesController = TextEditingController();
  
  late PromotionType _type;
  late DateTime _startDate;
  late DateTime _endDate;
  List<String> _selectedProductIds = [];
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final promotion = widget.promotion;
    if (promotion != null) {
      _titleController.text = promotion.title;
      _descriptionController.text = promotion.description;
      _valueController.text = promotion.value.toString();
      _type = promotion.type;
      _startDate = promotion.startDate;
      _endDate = promotion.endDate;
      _selectedProductIds = List.from(promotion.productIds);
      _imageUrl = promotion.imageUrl;
      if (promotion.minPurchaseAmount != null) {
        _minPurchaseController.text = promotion.minPurchaseAmount.toString();
      }
      if (promotion.maxUses != null) {
        _maxUsesController.text = promotion.maxUses.toString();
      }
    } else {
      _type = PromotionType.percentage;
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minPurchaseController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsStreamProvider);

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.promotion != null
                      ? 'Editar Promoción'
                      : 'Nueva Promoción',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Imagen
                if (_imageUrl != null)
                  Stack(
                    children: [
                      Image.network(
                        _imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => setState(() => _imageUrl = null),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Agregar imagen'),
                  ),
                const SizedBox(height: 16),
                // Título
                CustomTextField(
                  controller: _titleController,
                  label: 'Título',
                  hint: 'Ingrese el título de la promoción',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El título es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Descripción
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Ingrese la descripción de la promoción',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Tipo de promoción
                DropdownButtonFormField<PromotionType>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de promoción',
                  ),
                  items: PromotionType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPromotionTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Valor
                CustomTextField(
                  controller: _valueController,
                  label: _type == PromotionType.percentage
                      ? 'Porcentaje de descuento'
                      : _type == PromotionType.fixedAmount
                          ? 'Monto de descuento'
                          : 'Cantidad',
                  hint: _type == PromotionType.percentage
                      ? 'Ej: 20'
                      : _type == PromotionType.fixedAmount
                          ? 'Ej: 100'
                          : 'Ej: 2',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    final number = double.tryParse(value);
                    if (number == null) {
                      return 'Ingrese un número válido';
                    }
                    if (_type == PromotionType.percentage && (number < 0 || number > 100)) {
                      return 'El porcentaje debe estar entre 0 y 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Fechas
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDate(true),
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Inicio: ${_formatDate(_startDate)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDate(false),
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Fin: ${_formatDate(_endDate)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Productos aplicables
                productsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
                  data: (products) => _buildProductSelection(products),
                ),
                const SizedBox(height: 16),
                // Campos opcionales
                ExpansionTile(
                  title: const Text('Opciones adicionales'),
                  children: [
                    CustomTextField(
                      controller: _minPurchaseController,
                      label: 'Monto mínimo de compra',
                      hint: 'Ej: 100',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _maxUsesController,
                      label: 'Máximo de usos',
                      hint: 'Ej: 50',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _savePromotion,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.promotion != null ? 'Actualizar' : 'Crear',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSelection(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Productos aplicables:'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: products.map((product) {
            final isSelected = _selectedProductIds.contains(product.id);
            return FilterChip(
              label: Text(product.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedProductIds.add(product.id!);
                  } else {
                    _selectedProductIds.remove(product.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_selectedProductIds.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Selecciona al menos un producto',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  String _getPromotionTypeText(PromotionType type) {
    switch (type) {
      case PromotionType.percentage:
        return 'Porcentaje de descuento';
      case PromotionType.fixedAmount:
        return 'Monto fijo de descuento';
      case PromotionType.buyXGetY:
        return 'Compra X lleva Y';
      case PromotionType.bundle:
        return 'Combo de productos';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(bool isStart) async {
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

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final imgbbService = ImgBBService(apiKey: ApiKeys.imgBBApiKey);
      final imageUrl = await imgbbService.uploadPromotionImage(context);
      if (imageUrl != null) {
        setState(() => _imageUrl = imageUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un producto'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final commerceId = ref.read(currentCommerceIdProvider);
      if (commerceId == null) throw Exception('ID de comercio no válido');

      final promotion = Promotion(
        id: widget.promotion?.id,
        commerceId: commerceId,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _type,
        status: widget.promotion?.status ?? PromotionStatus.active,
        value: double.parse(_valueController.text),
        startDate: _startDate,
        endDate: _endDate,
        productIds: _selectedProductIds,
        minPurchaseAmount: _minPurchaseController.text.isNotEmpty
            ? double.parse(_minPurchaseController.text)
            : null,
        maxUses: _maxUsesController.text.isNotEmpty
            ? int.parse(_maxUsesController.text)
            : null,
        usedCount: widget.promotion?.usedCount ?? 0,
        imageUrl: _imageUrl,
      );

      final repository = ref.read(promotionRepositoryProvider);
      if (widget.promotion != null) {
        await repository.updatePromotion(promotion);
      } else {
        await repository.createPromotion(promotion);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 