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

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : widget.product?.imageUrl != null
                          ? NetworkImage(widget.product!.imageUrl!)
                          : null,
                  child:
                      _imageFile == null && widget.product?.imageUrl == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Nombre',
                hint: 'Nombre del producto',
                prefixIcon: Icons.shopping_bag,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stock',
                      hint: '0',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
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
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    ProductCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
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
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Producto Perecedero'),
                value: _isPerishable,
                onChanged: (value) {
                  setState(() {
                    _isPerishable = value ?? false;
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
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Requiere Refrigeración'),
                  value: _requiresRefrigeration,
                  onChanged: (value) {
                    setState(() {
                      _requiresRefrigeration = value ?? false;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.product == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
