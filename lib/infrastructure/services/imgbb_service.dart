import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImgBBService {
  final String apiKey; // Cambiado a miembro de instancia

  ImgBBService(this.apiKey); // Constructor que requiere apiKey

  Future<String?> uploadImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'), // Usa apiKey
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data']['url'];
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      // ignore: avoid_print
      print('Error uploading to ImgBB: $e');
      return null;
    }
  }

  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
