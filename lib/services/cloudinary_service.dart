import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;

class CloudinaryService {
  static const String cloudName = 'dgajwfncj';
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Upload preset name - you need to create this in your Cloudinary dashboard
  // Go to Settings > Upload > Upload presets and create an unsigned preset
  static const String uploadPreset = 'unsigned'; // Change this if you have a different preset name

  /// Upload an image file to Cloudinary
  /// Returns the secure URL of the uploaded image
  /// 
  /// Note: Make sure you have created an unsigned upload preset in your Cloudinary dashboard
  /// Settings > Upload > Upload presets > Add upload preset
  static Future<String?> uploadImage(File imageFile, {String? customUploadPreset}) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      
      // Add upload preset (use custom preset if provided, otherwise use default)
      request.fields['upload_preset'] = customUploadPreset ?? uploadPreset;
      
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['secure_url']; // Return the secure URL
      } else {
        debugPrint('Cloudinary upload error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload image from bytes (for web platform)
  /// Returns the secure URL of the uploaded image
  static Future<String?> uploadImageBytes(List<int> imageBytes, String fileName, {String? customUploadPreset}) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      // Add the image file as bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );
      
      // Add upload preset (use custom preset if provided, otherwise use default)
      request.fields['upload_preset'] = customUploadPreset ?? uploadPreset;
      
      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['secure_url']; // Return the secure URL
      } else {
        debugPrint('Cloudinary upload error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload image from file path
  static Future<String?> uploadImageFromPath(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await uploadImage(file);
    }
    return null;
  }
}

