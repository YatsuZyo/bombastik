import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

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
  final Dio _dio;
  final String _apiKey;
  static const String _baseUrl = 'https://api.imgbb.com/1';

  /// Crea una nueva instancia de ImgbbService
  ///
  /// [apiKey] - API key de ImgBB
  /// [dioOptions] - Opciones de configuración para Dio (opcional)
  ImgBBService({required String apiKey, BaseOptions? dioOptions})
    : _apiKey = apiKey,
      _dio = Dio(
        dioOptions ??
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              validateStatus: (status) => status != null && status < 500,
            ),
      );

  /// Sube una imagen a ImgBB y retorna la URL de la imagen
  ///
  /// Throws [ImgbbException] si hay algún error durante la subida
  Future<String> uploadImage(File imageFile) async {
    try {
      if (!await validateImage(imageFile)) {
        throw ImgbbException(
          'La imagen no cumple con los requisitos de validación',
        );
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final formData = FormData.fromMap({'key': _apiKey, 'image': base64Image});

      final response = await _dio.post('/upload', data: formData);

      if (response.statusCode != 200) {
        throw ImgbbException(
          'Error al subir la imagen: ${response.statusMessage}',
          response.data,
        );
      }

      if (response.data['success'] != true) {
        throw ImgbbException(
          'La subida falló: ${response.data['error']?['message'] ?? 'Error desconocido'}',
          response.data,
        );
      }

      return response.data['data']['url'] as String;
    } on DioException catch (e) {
      throw ImgbbException(_getDioErrorMessage(e), e);
    } catch (e) {
      throw ImgbbException('Error inesperado al subir la imagen', e);
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

  /// Selecciona una imagen del dispositivo
  Future<File?> pickImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al seleccionar la imagen')),
        );
      }
      return null;
    }
  }

  /// Valida que la imagen cumpla con los requisitos
  Future<bool> validateImage(File? imageFile) async {
    if (imageFile == null) return false;

    try {
      final bytes = await imageFile.readAsBytes();
      // Validar tamaño máximo (5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        throw ImgbbException('La imagen no debe superar los 5MB');
      }
      return true;
    } catch (e) {
      debugPrint('Error al validar imagen: $e');
      return false;
    }
  }

  /// Obtiene un mensaje de error amigable basado en el error de Dio
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de respuesta agotado';
      case DioExceptionType.badResponse:
        return 'Error en la respuesta del servidor: ${e.response?.statusMessage}';
      case DioExceptionType.cancel:
        return 'La solicitud fue cancelada';
      default:
        return 'Error de conexión: ${e.message}';
    }
  }

  Future<String?> uploadPromotionImage(BuildContext context) async {
    final image = await pickImage(
      context,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null) return null;

    return uploadImage(image);
  }
}
