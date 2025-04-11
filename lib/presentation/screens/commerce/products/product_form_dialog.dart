import 'package:bombastik/presentation/providers/commerce-providers/products/products_provider.dart';
import 'package:bombastik/presentation/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/product.dart';
import 'package:bombastik/domain/use_cases/product_controller.dart';
import 'package:bombastik/presentation/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _storageConditionsController = TextEditingController();
  final _expirationDateController = TextEditingController();

  ProductCategory _selectedCategory = ProductCategory.otros;
  bool _isPerishable = false;
  bool _requiresRefrigeration = false;
  File? _imageFile;
  DateTime? _expirationDate;
  bool _isLoading = false;

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
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.category;
      _isPerishable = widget.product!.isPerishable;
      _requiresRefrigeration = widget.product!.requiresRefrigeration;
      _storageConditionsController.text =
          widget.product!.storageConditions ?? '';
      if (widget.product!.expirationDate != null) {
        _expirationDate = widget.product!.expirationDate;
        _expirationDateController.text = _formatDate(_expirationDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _storageConditionsController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
        _expirationDateController.text = _formatDate(picked);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: widget.product?.id,
        commerceId: user.uid,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        isPerishable: _isPerishable,
        requiresRefrigeration: _requiresRefrigeration,
        storageConditions:
            _storageConditionsController.text.isNotEmpty
                ? _storageConditionsController.text
                : null,
        expirationDate: _expirationDate,
        imageUrl: widget.product?.imageUrl,
      );

      if (widget.product == null) {
        // Crear nuevo producto
        if (_imageFile != null) {
          await ref
              .read(productsProvider.notifier)
              .createProduct(product, _imageFile!, context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona una imagen')),
          );
          return;
        }
      } else {
        // Actualizar producto existente
        await ref
            .read(productsProvider.notifier)
            .updateProduct(product, _imageFile, context);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? colors.surface : colors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colors.primary,
                                      colors.primary.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  widget.product == null
                                      ? Icons.inventory_2_rounded
                                      : Icons.edit_attributes_rounded,
                                  color: colors.onPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.product == null
                                      ? 'Nuevo Producto'
                                      : 'Editar Producto',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onSurface,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colors.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                                image:
                                    _imageFile != null
                                        ? DecorationImage(
                                          image: FileImage(_imageFile!),
                                          fit: BoxFit.cover,
                                        )
                                        : widget.product?.imageUrl != null
                                        ? DecorationImage(
                                          image: NetworkImage(
                                            widget.product!.imageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : null,
                              ),
                              child:
                                  _imageFile == null &&
                                          widget.product?.imageUrl == null
                                      ? Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: colors.primary,
                                      )
                                      : null,
                            ),
                          ),
                          if (_imageFile != null ||
                              widget.product?.imageUrl != null)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Nombre del producto',
                      prefixIcon: Icons.shopping_bag,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el nombre del producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint: 'Descripción del producto',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la descripción del producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Precio',
                            hint: '0.00',
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese el precio';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingrese un precio válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _stockController,
                            label: 'Stock',
                            hint: '0',
                            prefixIcon: Icons.inventory,
                            keyboardType: TextInputType.number,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese el stock';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Ingrese un stock válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outline.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductCategory>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: colors.primary,
                          ),
                          items:
                              ProductCategory.values.map((category) {
                                final name =
                                    category.toString().split('.').last;
                                final capitalizedName =
                                    name[0].toUpperCase() + name.substring(1);
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          categoryIcons[category] ??
                                              Icons.category,
                                          color: colors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        capitalizedName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: colors.onSurface,
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
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Adicional',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(
                              'Producto Perecedero',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurface,
                              ),
                            ),
                            value: _isPerishable,
                            activeColor: colors.primary,
                            onChanged: (value) {
                              setState(() {
                                _isPerishable = value;
                              });
                            },
                          ),
                          if (_isPerishable) ...[
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _expirationDateController,
                              label: 'Fecha de Vencimiento',
                              hint: 'DD/MM/YYYY',
                              prefixIcon: Icons.calendar_today,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _storageConditionsController,
                              label: 'Condiciones de Almacenamiento',
                              hint: 'Temperatura, humedad, etc.',
                              prefixIcon: Icons.ac_unit,
                              maxLines: 2,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text(
                                'Requiere Refrigeración',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurface,
                                ),
                              ),
                              value: _requiresRefrigeration,
                              activeColor: colors.primary,
                              onChanged: (value) {
                                setState(() {
                                  _requiresRefrigeration = value;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colors.onPrimary,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    widget.product == null
                                        ? 'Crear'
                                        : 'Actualizar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onPrimary,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
