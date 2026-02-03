import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class UserManagementService {
  static const String baseUrl = AppConfig.baseUrl;

  /// GET /user/get-customers-filtered. Query: country, city, gender, ageGroup, isActive, subscriptionId, categoryId, isSingleClass.
  Future<List<dynamic>> getCustomersFiltered({
    String? country,
    String? city,
    String? gender,
    String? ageGroup,
    bool? isActive,
    String? subscriptionId,
    String? categoryId,
    bool? isSingleClass,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (country != null && country.isNotEmpty) queryParams['country'] = country;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
      if (ageGroup != null && ageGroup.isNotEmpty) queryParams['ageGroup'] = ageGroup;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (subscriptionId != null && subscriptionId.isNotEmpty) queryParams['subscriptionId'] = subscriptionId;
      if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;
      if (isSingleClass != null) queryParams['isSingleClass'] = isSingleClass.toString();

      final response = await ApiService.get(
        '$baseUrl/user/get-customers-filtered',
        requireAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['users'] is List) return data['users'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get customers');
    } catch (e) {
      throw Exception('Get customers filtered error: ${e.toString()}');
    }
  }

  /// GET /user/get-userby-id/:id — single user/customer by ID. Requires JWT.
  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/user/get-userby-id/$id',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get user');
    } catch (e) {
      throw Exception('Get user by id error: ${e.toString()}');
    }
  }

  /// GET /user/get-all-user — all users (any role). Filter by role on frontend for "all customers". Requires JWT.
  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/user/get-all-user',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['users'] is List) return data['users'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get users');
    } catch (e) {
      throw Exception('Get all users error: ${e.toString()}');
    }
  }

  /// DELETE /user/delete-user/:id
  Future<Map<String, dynamic>?> deleteUser(String userId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/user/delete-user/$userId',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete user');
    } catch (e) {
      throw Exception('Delete user error: ${e.toString()}');
    }
  }
  
  // 2.1 Update User Status
  Future<Map<String, dynamic>?> updateUserStatus({
    required String userId,
    required String status, // "Approved", "Pending", "Rejected"
  }) async {
    try {
      final response = await ApiService.patch(
        '$baseUrl/user/update-user-status/$userId',
        {'status': status},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update user status');
      }
    } catch (e) {
      throw Exception('Update user status error: ${e.toString()}');
    }
  }
  
  // 2.2 Create User (Admin only) - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> createUser({
    required File? profileImage,
    required String email,
    required String userRole, // Role ID (ObjectId or role_id)
    required String firstName,
    String? lastName,
    String? phoneNumber,
    required String emiratesId,
    String? gender,
    String? address,
    int? age,
    String? country, // Country ID (ObjectId)
    String? city, // City ID (ObjectId)
    String? specialization,
    String? experience,
    int? experienceYear,
    required String password,
  }) async {
    try {
      final fields = {
        'email': email.trim(),
        'user_role': userRole,
        'first_name': firstName.trim(),
        'emirates_id': emiratesId.trim(),
        'password': password,
      };
      
      // Add optional fields
      if (lastName != null && lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        fields['phone_number'] = phoneNumber.trim();
      }
      if (gender != null && gender.trim().isNotEmpty) {
        fields['gender'] = gender.trim();
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
      if (experience != null && experience.trim().isNotEmpty) {
        fields['experience'] = experience.trim();
      }
      if (experienceYear != null && experienceYear >= 0) {
        fields['experienceYear'] = experienceYear.toString();
      }
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.postMultipart(
        '$baseUrl/user/create-user',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create user');
      }
    } catch (e) {
      throw Exception('Create user error: ${e.toString()}');
    }
  }
  
  // 2.3 Update User - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> updateUser({
    File? profileImage,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final fields = <String, dynamic>{};
      
      if (email != null && email.trim().isNotEmpty) {
        fields['email'] = email.trim();
      }
      if (firstName != null && firstName.trim().isNotEmpty) {
        fields['first_name'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        fields['last_name'] = lastName.trim();
      }
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        fields['phone_number'] = phoneNumber.trim();
      }
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.putMultipart(
        '$baseUrl/user/update-user',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Update user error: ${e.toString()}');
    }
  }
  
  // 2.16 Cancel Order by Customer
  // Note: Backend route has double colons (::orderDetailsId) which appears to be a typo
  Future<Map<String, dynamic>?> cancelOrderByCustomer({
    required String orderDetailsId,
  }) async {
    try {
      // Note: The API docs show ::orderDetailsId (double colons) which is likely a typo
      // Using single colon as that's the standard Express.js route parameter syntax
      final response = await ApiService.put(
        '$baseUrl/user/cancel-by-customer/$orderDetailsId',
        {'bookingStatus': 'CANCEL'},
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Cancel order error: ${e.toString()}');
    }
  }
}

