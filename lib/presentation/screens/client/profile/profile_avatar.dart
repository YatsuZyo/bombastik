// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:bombastik/presentation/providers/client-providers/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileAvatar extends ConsumerWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onEditPressed;
  final Function(String)? onImageUploaded; // Cambiad
  final Function(File)? onImageSelected;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 50,
    this.onEditPressed,
    this.onImageUploaded,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onEditPressed ?? () => _handleImageChange(ref, context),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2),
            child: _buildAvatarContent(context),
          ),
        ),
        Positioned(
          bottom: -5,
          right: -5,
          child: IconButton(
            icon: Icon(Icons.edit, size: radius * 0.35, color: Colors.white),
            onPressed: onEditPressed ?? () => _handleImageChange(ref, context),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget:
              (context, url, error) => Icon(Icons.person, size: radius),
        ),
      );
    }
    return Icon(Icons.person, size: radius);
  }

  Future<void> _handleImageChange(WidgetRef ref, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final notifier = ref.read(profileProvider.notifier);

      try {
        final newUrl = await notifier.uploadAndUpdateProfileImage(imageFile);
        if (newUrl != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Foto de perfil actualizada')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar imagen: ${e.toString()}')),
        );
      }
    }
  }
}
