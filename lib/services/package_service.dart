import 'dart:convert';
import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class PackageService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 15.1 Create Package
  // POST /api/v1/package/create-package (multipart)
  // duration: "daily" | "weekly" | "monthly"; numberOfClasses (required); features optional
  Future<Map<String, dynamic>?> createPackage({
    File? image,
    String? imageUrl,
    required String name,
    String? description,
    List<String>? features,
    required double price,
    required String duration, // "daily" | "weekly" | "monthly"
    required int numberOfClasses,
    required bool isActive,
  }) async {
    try {
      final fields = <String, dynamic>{
        'name': name,
        'price': price.toString(),
        'numberOfClasses': numberOfClasses.toString(),
        'duration': duration,
        'isActive': isActive.toString(),
      };
      if (description != null && description.trim().isNotEmpty) {
        fields['description'] = description.trim();
      }
      if (features != null && features.isNotEmpty) {
        fields['features'] = jsonEncode(features);
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        fields['imageUrl'] = imageUrl;
      }
      final files = image != null ? {'image': image} : null;
      print('Creating package with fields: $fields');
      print('Image file: ${image?.path}');
      final response = await ApiService.postMultipart(
        '$baseUrl/package/create-package',
        fields,
        files: files,
        requireAuth: true,
      );
      
      print('Package creation response: $response');
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        final errorMsg = response['error'] ?? 
                        response['message'] ?? 
                        response['data']?['message'] ??
                        'Failed to create package';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Package creation error: ${e.toString()}');
      // Extract meaningful error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Failed to create package: $errorMessage');
    }
  }
  
  // 15.2 Update Package
  Future<Map<String, dynamic>?> updatePackage({
    required String packageId,
    File? image,
    String? name,
    double? price,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['name'] = name;
      if (price != null) fields['price'] = price.toString();
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/package/update-package/$packageId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update package');
      }
    } catch (e) {
      throw Exception('Update package error: ${e.toString()}');
    }
  }
  
  // 15.3 Get All Packages
  Future<Map<String, dynamic>?> getAllPackages({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final payload = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      
      print('Fetching packages with payload: $payload');
      
      final response = await ApiService.post(
        '$baseUrl/package/get-all-packages',
        payload,
        requireAuth: false, // Same as membership carousel (public list)
      );
      
      print('Get packages response: $response');
      
      if (response['success'] == true) {
        // Handle different response structures
        final data = response['data'];
        if (data != null) {
          return data;
        }
        // If data is null, return empty structure
        return {'packages': [], 'data': []};
      } else {
        final errorMsg = response['error'] ?? 
                        response['message'] ?? 
                        response['data']?['message'] ??
                        'Failed to get packages';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Get packages error: ${e.toString()}');
      // Extract meaningful error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      throw Exception('Failed to load packages: $errorMessage');
    }
  }
  
  // 15.4 Get Package by ID
  Future<Map<String, dynamic>?> getPackageById({
    required String packageId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/package/get-package-by-id/$packageId',
        requireAuth: false, // Public route
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get package');
      }
    } catch (e) {
      throw Exception('Get package by ID error: ${e.toString()}');
    }
  }
  
  // 15.5 Delete Package (Admin only)
  Future<Map<String, dynamic>?> deletePackage({
    required String packageId,
  }) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/package/delete-package/$packageId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to delete package');
      }
    } catch (e) {
      throw Exception('Delete package error: ${e.toString()}');
    }
  }
}

