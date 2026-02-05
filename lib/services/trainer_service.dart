import 'dart:io';
import 'dart:convert';
import 'api_service.dart';
import '../config/app_config.dart';

class TrainerService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 5.1 Create Trainer
  // POST /api/v1/trainer/create-trainer (multipart/form-data)
  // Required: email, first_name, emirates_id, phone_number, password
  // Optional: last_name, gender, address, age, country (ObjectId), city (ObjectId),
  //           specialization, experience (free text), experienceYear, serviceProvider (JSON array string)
  // Optional files: profile_image, id_proof, certificate (one each)
  Future<Map<String, dynamic>?> createTrainer({
    File? profileImage,
    File? idProof,
    File? certificate,
    required String email,
    required String firstName,
    String? lastName,
    required String phoneNumber,
    required String emiratesId,
    String? gender,
    String? address,
    int? age,
    String? country,
    String? city,
    String? specialization,
    String? experience,
    int? experienceYear,
    required String password,
    List<String>? serviceProvider,
  }) async {
    try {
      final trimmedEmiratesId = emiratesId.trim();
      if (trimmedEmiratesId.isEmpty) {
        throw Exception('Emirates ID is required');
      }
      // API: max 20 chars for emirates_id; send as-is (with or without dashes)
      final emiratesIdValue = trimmedEmiratesId.length > 20
          ? trimmedEmiratesId.substring(0, 20)
          : trimmedEmiratesId;

      final fields = <String, dynamic>{
        'email': email.trim(),
        'first_name': firstName.trim(),
        'phone_number': phoneNumber.trim(),
        'password': password,
        'emirates_id': emiratesIdValue,
      };
      if (lastName != null && lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (gender != null && gender.trim().isNotEmpty) {
        String g = gender.trim();
        if (g.toLowerCase() == 'male') g = 'Male';
        else if (g.toLowerCase() == 'female') g = 'Female';
        else if (g.toLowerCase() == 'other' || g.toLowerCase() == 'others') g = 'Others';
        fields['gender'] = g;
      }
      if (address != null && address.trim().isNotEmpty) {
        fields['address'] = address.trim();
      }
      if (age != null && age > 0) {
        fields['age'] = age.toString();
      }
      if (country != null && country.trim().isNotEmpty) {
        fields['country'] = country.trim();
      }
      if (city != null && city.trim().isNotEmpty) {
        fields['city'] = city.trim();
      }
      if (specialization != null && specialization.trim().isNotEmpty) {
        fields['specialization'] = specialization.trim();
      }
      // Backend expects enum: EXPERIENCE | FRESHER
      if (experience != null && experience.trim().isNotEmpty) {
        final v = experience.trim().toUpperCase();
        if (v == 'EXPERIENCE' || v == 'FRESHER') {
          fields['experience'] = v;
        }
      }
      if (experienceYear != null && experienceYear >= 0) {
        fields['experienceYear'] = experienceYear.toString();
      }
      fields['serviceProvider'] = jsonEncode(serviceProvider ?? []);

      final files = <String, File>{};
      if (profileImage != null) files['profile_image'] = profileImage;
      if (idProof != null) files['id_proof'] = idProof;
      if (certificate != null) files['certificate'] = certificate;
      final filesMap = files.isEmpty ? null : files;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/trainer/create-trainer',
        fields,
        files: filesMap,
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

