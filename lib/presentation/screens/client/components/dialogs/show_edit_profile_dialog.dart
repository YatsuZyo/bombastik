import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombastik/domain/models/user_profile.dart';
import 'package:bombastik/presentation/providers/client-providers/profile/profile_provider.dart';

Widget showEditProfileDialog({
  required BuildContext context,
  required WidgetRef ref,
  required UserProfile currentProfile,
  bool isStandalone = false,
}) {
  final theme = Theme.of(context);
  final phoneController = TextEditingController(text: currentProfile.phone);
  final addressController = TextEditingController(text: currentProfile.address);

  final dialogContent = AlertDialog(
    title: Text('Editar perfil', style: theme.textTheme.headlineMedium),
    backgroundColor: theme.colorScheme.surface,
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre (solo lectura)
          TextField(
            controller: TextEditingController(text: currentProfile.name),
            decoration: const InputDecoration(
              labelText: 'Nombre',
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // Email (solo lectura)
          TextField(
            controller: TextEditingController(text: currentProfile.email),
            decoration: const InputDecoration(
              labelText: 'Email',
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // Teléfono (editable)
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Dirección (editable)
          TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: 'Dirección'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          'Cancelar',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          ref.read(profileProvider.notifier).updateProfileData({
            'phone': phoneController.text,
            'address': addressController.text,
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Text(
          'Guardar',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  if (isStandalone) {
    return dialogContent;
  } else {
    showDialog(context: context, builder: (context) => dialogContent);
    return const SizedBox.shrink();
  }
}
