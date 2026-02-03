import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class SubServiceService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 4.1 Create Sub Service
  Future<Map<String, dynamic>?> createSubService({
    File? image,
    String? imageUrl,
    required String name,
    required String serviceTypeId,
    required String groomingDetails,
  }) async {
    try {
      final fields = {
        'name': name,
        'serviceTypeId': serviceTypeId,
        'groomingDetails': groomingDetails,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/subservice/createSubService',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create sub service');
      }
    } catch (e) {
      throw Exception('Create sub service error: ${e.toString()}');
    }
  }
  
  // 4.2 Update Sub Service
  Future<Map<String, dynamic>?> updateSubService({
    required String subServiceId,
    File? image,
    String? name,
    String? groomingDetails,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['name'] = name;
      if (groomingDetails != null) fields['groomingDetails'] = groomingDetails;
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/subservice/updateSubService/$subServiceId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update sub service');
      }
    } catch (e) {
      throw Exception('Update sub service error: ${e.toString()}');
    }
  }
  
  // 4.3 Get All Sub Services
  Future<Map<String, dynamic>?> getAllSubServices({
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
      
      final response = await ApiService.post(
        '$baseUrl/subservice/getAllSubService',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get sub services');
      }
    } catch (e) {
      throw Exception('Get all sub services error: ${e.toString()}');
    }
  }

  /// GET /subservice/getSubServiceById/:subServiceId
  Future<Map<String, dynamic>?> getSubServiceById(String subServiceId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/subservice/getSubServiceById/$subServiceId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get sub service');
    } catch (e) {
      throw Exception('Get sub service by ID error: ${e.toString()}');
    }
  }

  /// DELETE /subservice/deleteSubService/:subServiceId
  Future<Map<String, dynamic>?> deleteSubService(String subServiceId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/subservice/deleteSubService/$subServiceId',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete sub service');
    } catch (e) {
      throw Exception('Delete sub service error: ${e.toString()}');
    }
  }
}

