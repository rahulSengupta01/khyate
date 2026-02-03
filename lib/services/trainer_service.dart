import 'dart:io';
import 'dart:convert';
import 'api_service.dart';
import '../config/app_config.dart';

class TrainerService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 5.1 Create Trainer
  Future<Map<String, dynamic>?> createTrainer({
    File? profileImage,
    String? profileImageUrl,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String emiratesId,
    required String gender,
    required String address,
    required int age,
    required String country,
    required String city,
    required String specialization,
    required String experience,
    required int experienceYear,
    required String password,
    required List<String> serviceProvider,
  }) async {
    try {
      // Build fields map - trim all string fields and ensure proper formatting
      // Gender must be: "Male", "Female", "Others" (capitalized)
      // Experience must be: "EXPERIENCE" or "FRESHER"
      // User enters a single Emirates ID in the form; we send that one value under the backend's expected key(s).
      final trimmedEmiratesId = emiratesId.trim();
      final effectiveEmiratesId = trimmedEmiratesId.isEmpty
          ? 'TEMP-${DateTime.now().millisecondsSinceEpoch}'
          : trimmedEmiratesId;

      final fields = <String, dynamic>{
        'email': email.trim(),
        'first_name': firstName.trim(),
        'phone_number': phoneNumber.trim(),
        'emirates_id': effectiveEmiratesId,
        'emiratesId': effectiveEmiratesId,
        'password': password,
      };
      
      // Fix gender to match enum: "Male", "Female", "Others"
      String normalizedGender = gender.trim();
      if (normalizedGender.toLowerCase() == 'male') {
        normalizedGender = 'Male';
      } else if (normalizedGender.toLowerCase() == 'female') {
        normalizedGender = 'Female';
      } else if (normalizedGender.toLowerCase() == 'other' || normalizedGender.toLowerCase() == 'others') {
        normalizedGender = 'Others';
      }
      
      // Fix experience to match enum: "EXPERIENCE" or "FRESHER"
      String normalizedExperience = experience.trim().toUpperCase();
      if (normalizedExperience == 'YES' || normalizedExperience == 'EXPERIENCED' || normalizedExperience == 'HAS EXPERIENCE') {
        normalizedExperience = 'EXPERIENCE';
      } else if (normalizedExperience == 'NO' || normalizedExperience == 'FRESH' || normalizedExperience == 'NEW') {
        normalizedExperience = 'FRESHER';
      }
      
      // Add optional fields - send them if provided (backend handles undefined)
      if (lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (normalizedGender.isNotEmpty) {
        fields['gender'] = normalizedGender;
      }
      if (address.trim().isNotEmpty) {
        fields['address'] = address.trim();
      }
      if (age > 0) {
        fields['age'] = age.toString();
      }
      if (country.trim().isNotEmpty) {
        fields['country'] = country.trim();
      }
      if (city.trim().isNotEmpty) {
        fields['city'] = city.trim();
      }
      if (specialization.trim().isNotEmpty) {
        fields['specialization'] = specialization.trim();
      }
      if (normalizedExperience.isNotEmpty) {
        fields['experience'] = normalizedExperience;
      }
      // Many backends expect FRESHER to have 0 experience years; send 0 to avoid 400 validation
      final effectiveExperienceYear = normalizedExperience == 'FRESHER' ? 0 : experienceYear;
      if (effectiveExperienceYear >= 0) {
        fields['experienceYear'] = effectiveExperienceYear.toString();
      }
      
      // Handle serviceProvider - send as JSON string (empty array is valid). Backend may parse with JSON.parse().
      fields['serviceProvider'] = jsonEncode(serviceProvider);
      
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        fields['profileImageUrl'] = profileImageUrl;
      }
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/trainer/create-trainer',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        // Backend returns { statusCode, data, message, success }
        // Our ApiService wraps it, so data might be the full response or just the data field
        final responseData = response['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          return responseData['data'];
        }
        return responseData;
      } else {
        // Surface backend 400/validation message so user sees the real reason
        String errorMsg = response['error'] ?? 'Failed to create trainer';
        final data = response['data'];
        if (data is Map) {
          final msg = data['message'] ?? data['error'] ?? data['msg'];
          if (msg != null && msg.toString().trim().isNotEmpty) {
            errorMsg = msg.toString();
          }
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map) {
              final parts = errors.entries.map((e) => '${e.key}: ${e.value}').toList();
              if (parts.isNotEmpty) {
                errorMsg = errorMsg + (errorMsg.endsWith('.') ? ' ' : '. ') + parts.join('; ');
              }
            } else if (errors is List) {
              final parts = errors.map((e) => e.toString()).toList();
              if (parts.isNotEmpty) {
                errorMsg = errorMsg + (errorMsg.endsWith('.') ? ' ' : '. ') + parts.join('; ');
              }
            }
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Create trainer error: ${e.toString()}');
    }
  }
  
  // 5.2 Update Trainer
  Future<Map<String, dynamic>?> updateTrainer({
    required String trainerId,
    File? profileImage,
    String? firstName,
    String? lastName,
    String? specialization,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (specialization != null) fields['specialization'] = specialization;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/trainer/update-trainer/$trainerId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer');
      }
    } catch (e) {
      throw Exception('Update trainer error: ${e.toString()}');
    }
  }
  
  // 5.3 Update Trainer Status
  Future<Map<String, dynamic>?> updateTrainerStatus({
    required String trainerId,
    required String status,
  }) async {
    try {
      final response = await ApiService.patch(
        '$baseUrl/trainer/update-trainer-status/$trainerId',
        {'status': status},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer status');
      }
    } catch (e) {
      throw Exception('Update trainer status error: ${e.toString()}');
    }
  }
  
  // 5.4 Update Trainer Profile (By Trainer)
  Future<Map<String, dynamic>?> updateTrainerProfile({
    required String trainerId,
    File? profileImage,
    String? firstName,
    String? lastName,
    String? specialization,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (specialization != null) fields['specialization'] = specialization;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/trainer/update-trainer-profiles/$trainerId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update trainer profile');
      }
    } catch (e) {
      throw Exception('Update trainer profile error: ${e.toString()}');
    }
  }
  
  // 5.5 Get All Assigned Jobs
  Future<Map<String, dynamic>?> getAllAssignedJobs({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final payload = {
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      
      final response = await ApiService.post(
        '$baseUrl/trainer/get-all-assigned-jobs',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get assigned jobs');
      }
    } catch (e) {
      throw Exception('Get assigned jobs error: ${e.toString()}');
    }
  }
  
  // 5.6 Trainer Check-in
  Future<Map<String, dynamic>?> checkin({
    required String orderDetailsId,
    required String checkinTime,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/checkin/$orderDetailsId',
        {
          'checkinTime': checkinTime,
          'latitude': latitude,
          'longitude': longitude,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to check-in');
      }
    } catch (e) {
      throw Exception('Check-in error: ${e.toString()}');
    }
  }
  
  // 5.7 Initiate Checkout
  Future<Map<String, dynamic>?> initiateCheckout({
    required String orderDetailsId,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/initiate-checkout/$orderDetailsId',
        {
          if (notes != null) 'notes': notes,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to initiate checkout');
      }
    } catch (e) {
      throw Exception('Initiate checkout error: ${e.toString()}');
    }
  }
  
  // 5.8 Complete Checkout
  Future<Map<String, dynamic>?> completeCheckout({
    required String orderDetailsId,
    required String completionTime,
    required List<String> images,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/trainer/complete-checkout/$orderDetailsId',
        {
          'completionTime': completionTime,
          'images': images,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to complete checkout');
      }
    } catch (e) {
      throw Exception('Complete checkout error: ${e.toString()}');
    }
  }
  
  // Get All Trainers
  Future<List<dynamic>> getAllTrainers() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/trainer/get-all-trainers',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'];
        if (data is Map && data['trainers'] is List) return data['trainers'];
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get trainers');
      }
    } catch (e) {
      throw Exception('Get trainers error: ${e.toString()}');
    }
  }

  /// GET /trainer/get-trainerBy-id/:id
  Future<Map<String, dynamic>?> getTrainerById(String trainerId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/trainer/get-trainerBy-id/$trainerId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get trainer');
    } catch (e) {
      throw Exception('Get trainer by ID error: ${e.toString()}');
    }
  }

  /// DELETE /trainer/delete-trainer/:id
  Future<Map<String, dynamic>?> deleteTrainer(String trainerId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/trainer/delete-trainer/$trainerId',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete trainer');
    } catch (e) {
      throw Exception('Delete trainer error: ${e.toString()}');
    }
  }

  /// GET /trainer/get-all-orders (Trainer's orders)
  Future<List<dynamic>> getAllOrders() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/trainer/get-all-orders',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['orders'] is List) return data['orders'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get orders');
    } catch (e) {
      throw Exception('Get all orders error: ${e.toString()}');
    }
  }

  /// GET /trainer/get-all-order-by-id/:id
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/trainer/get-all-order-by-id/$orderId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get order');
    } catch (e) {
      throw Exception('Get order by ID error: ${e.toString()}');
    }
  }
}

