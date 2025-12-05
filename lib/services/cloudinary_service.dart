import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  late CloudinaryPublic cloudinary;
  
  // Load from .env file
  static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  
  CloudinaryService() {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      debugPrint('⚠️ Warning: Cloudinary credentials not found in .env file');
    }
    cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }
  
  /// Upload image to Cloudinary
  /// Returns the secure URL of uploaded image
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      debugPrint('Uploading image to Cloudinary...');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? 'sportofolio/posts',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      debugPrint('Image uploaded successfully: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
    }
  }
  
  /// Upload multiple images
  /// Returns list of secure URLs
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String? folder,
    Function(int, int)? onProgress,
  }) async {
    List<String> urls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint('Uploading image ${i + 1}/${imageFiles.length}');
      
      String? url = await uploadImage(imageFiles[i], folder: folder);
      if (url != null) {
        urls.add(url);
      }
      
      // Call progress callback
      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }
    }
    
    return urls;
  }
  
  /// Upload video to Cloudinary
  /// Returns the secure URL of uploaded video
  Future<String?> uploadVideo(File videoFile, {String? folder}) async {
    try {
      debugPrint('Uploading video to Cloudinary...');
      
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          videoFile.path,
          folder: folder ?? 'sportofolio/videos',
          resourceType: CloudinaryResourceType.Video,
        ),
      );
      
      debugPrint('Video uploaded successfully: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading video to Cloudinary: $e');
      return null;
    }
  }
  
  /// Extract public ID from Cloudinary URL
  /// Example: https://res.cloudinary.com/demo/image/upload/v1234567890/sportofolio/posts/abc123.jpg
  /// Returns: sportofolio/posts/abc123
  String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find 'upload' segment and get everything after it
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return null;
      
      // Join segments after version number (v1234567890)
      final publicIdParts = pathSegments.skip(uploadIndex + 2);
      final publicIdWithExtension = publicIdParts.join('/');
      
      // Remove file extension
      final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
      if (lastDotIndex == -1) return publicIdWithExtension;
      
      final publicId = publicIdWithExtension.substring(0, lastDotIndex);
      
      return publicId;
    } catch (e) {
      debugPrint('Error extracting public ID: $e');
      return null;
    }
  }
  
  /// Get thumbnail URL from original Cloudinary URL
  /// Size: width and height in pixels (default: 200)
  String getThumbnailUrl(String originalUrl, {int size = 200}) {
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/w_$size,h_$size,c_fill,f_auto,q_auto/',
    );
  }
  
  /// Get optimized URL with automatic format and quality
  String getOptimizedUrl(String originalUrl) {
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/f_auto,q_auto/',
    );
  }
  
  /// Get square cropped URL (1:1 aspect ratio)
  String getSquareUrl(String originalUrl, {int size = 400}) {
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/w_$size,h_$size,ar_1:1,c_fill,f_auto,q_auto/',
    );
  }
  
  /// Get URL with custom transformations
  /// Example: getTransformedUrl(url, 'w_500,h_300,c_fit')
  String getTransformedUrl(String originalUrl, String transformations) {
    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/$transformations/',
    );
  }
  
  /// Compress image before upload (optional, for better performance)
  /// This reduces file size while maintaining quality
  Future<File?> compressImage(File imageFile) async {
    try {
      // You can use packages like flutter_image_compress here
      // For now, returning the original file
      return imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }
}
