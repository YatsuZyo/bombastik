import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;

/// Excepción personalizada para errores del servicio ImgBB
class ImgbbException implements Exception {
  final String message;
  final dynamic originalError;

  ImgbbException(this.message, [this.originalError]);

  @override
  String toString() =>
      'ImgbbException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Servicio para gestionar la subida de imágenes a ImgBB
class ImgBBService {
  final String apiKey;
  final Dio _dio;
  static const String _baseUrl = 'https://api.imgbb.com/1';

  ImgBBService({required this.apiKey})
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  /// Selecciona una imagen del dispositivo
  Future<File?> pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return null;

      final File originalFile = File(image.path);
      if (!await validateImage(originalFile)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen debe ser menor a 5MB'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return null;
      }

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Logo',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            hideBottomControls: true,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            cropFrameColor: Theme.of(context).colorScheme.primary,
            cropGridColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            showCropGrid: false,
            dimmedLayerColor: Colors.black.withOpacity(0.5),
            statusBarColor: Theme.of(context).colorScheme.primary,
          ),
          IOSUiSettings(
            title: 'Recortar Logo',
            doneButtonTitle: 'Aceptar',
            cancelButtonTitle: 'Cancelar',
            aspectRatioLockEnabled: true,
            minimumAspectRatio: 1.0,
            rotateButtonsHidden: true,
            resetButtonHidden: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile == null) return null;

      final croppedImageFile = File(croppedFile.path);
      if (!await croppedImageFile.exists()) {
        throw Exception('El archivo recortado no existe');
      }

      return croppedImageFile;
    } catch (e) {
      debugPrint('Error en pickImage: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la imagen: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  /// Sube una imagen a ImgBB
  Future<String?> uploadImage(File imageFile) async {
    try {
      if (!await validateImage(imageFile)) {
        throw Exception('La imagen no cumple con los requisitos de validación');
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final formData = FormData.fromMap({
        'key': apiKey,
        'image': base64Image,
      });

      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(
          'Error al subir la imagen: ${response.data['error']?['message'] ?? 'Error desconocido'}',
        );
      }

      return response.data['data']['url'] as String;
    } catch (e) {
      debugPrint('Error en uploadImage: $e');
      rethrow;
    }
  }

  /// Sube una imagen de perfil
  Future<String?> uploadProfileImage(File imageFile) async {
    return await uploadImage(imageFile);
  }

  /// Sube una imagen de producto
  Future<String?> uploadProductImage(File imageFile) async {
    return await uploadImage(imageFile);
  }

  /// Valida que la imagen cumpla con los requisitos
  Future<bool> validateImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return bytes.length <= 5 * 1024 * 1024; // 5MB
    } catch (e) {
      debugPrint('Error en validateImage: $e');
      return false;
    }
  }

  Future<String?> uploadPromotionImage(BuildContext context) async {
    final image = await pickImage(context);

    if (image == null) return null;

    return uploadImage(image);
  }
}
