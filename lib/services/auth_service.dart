import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 1.2 Register new user - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int userRole, // Role ID: 3 for customer, 2 for trainer
    required String country, // Country ID (ObjectId)
    required String city, // City ID (ObjectId)
    required String gender,
    required String address,
    required String emiratesId,
    required int age,
    File? profileImage, // Changed from String? to File? for multipart upload
    String? phoneNumber, // Backend may require phone_number
    String? uid, // Firebase UID if using social auth
  }) async {
    try {
      // Build payload: backend expects req.body (JSON); multipart leaves req.body {} in Express
      final Map<String, dynamic> payload = {};
      void setIfNonEmpty(String key, dynamic value) {
        if (value == null) return;
        final s = value.toString().trim();
        if (s.isNotEmpty) payload[key] = s;
      }
      setIfNonEmpty('email', email);
      setIfNonEmpty('password', password);
      payload['user_role'] = userRole;
      setIfNonEmpty('first_name', firstName);
      setIfNonEmpty('last_name', lastName);
      setIfNonEmpty('country', country);
      setIfNonEmpty('city', city);
      setIfNonEmpty('gender', gender);
      setIfNonEmpty('address', address);
      setIfNonEmpty('emirates_id', emiratesId);
      payload['age'] = age;
      setIfNonEmpty('phone_number', phoneNumber);
      if (uid != null && uid.toString().trim().isNotEmpty) payload['uid'] = uid.toString().trim();

      final Map<String, dynamic> response;
      if (profileImage != null) {
        // With file: use multipart (backend must parse multipart into body for this route)
        final fields = payload.map((k, v) => MapEntry(k, v?.toString() ?? ''));
        response = await ApiService.postMultipart(
          '$baseUrl/auth/register',
          fields,
          files: {'profile_image': profileImage},
          requireAuth: false,
        );
      } else {
        // No file: send JSON so backend req.body is populated
        response = await ApiService.post(
          '$baseUrl/auth/register',
          payload,
          requireAuth: false,
        );
      }
      
      if (response['success'] == true) {
        // Save token if provided
        final data = response['data'];
        if (data != null) {
          // Check for different possible token field names
          final token = data['accessToken'] ?? 
                       data['access_token'] ?? 
                       data['token'] ?? 
                       data['data']?['accessToken'] ??
                       data['data']?['access_token'];
          
          if (token != null) {
            await ApiService.saveToken(token);
          }
        }
        return data;
      } else {
        // Surface full backend error (e.g. "Missing required field: phone_number")
        final err = response['error'] ?? response['message'];
        final data = response['data'];
        String msg = err?.toString() ?? 'Registration failed';
        if (data is Map && (data['message'] != null || data['field'] != null)) {
          final detail = data['message'] ?? data['field'];
          if (detail != null) msg = '$msg. $detail';
        }
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  // Login user
  Future<Map<String, dynamic>?> signIn(
    String emailOrPhone,
    String password, {
    int roleId = 3, // Default to customer role (3), admin = 1
    String? provider, // "google" or "apple"
    String? uid, // Firebase UID if using social auth
  }) async {
    try {
      final payload = {
        'emailOrPhone': emailOrPhone,
        'password': password,
        if (provider != null && provider.isNotEmpty) 'provider': provider,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
      };
      
      final response = await ApiService.post(
        '$baseUrl/auth/login/$roleId',
        payload,
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        // The backend response structure: { statusCode, data: { user, accessToken, ... }, message, success }
        // ApiService wraps it: { success: true, data: <backend_response> }
        final backendResponse = response['data'];
        // Handle both nested structure (backendResponse['data']) and direct structure
        final actualData = (backendResponse is Map && backendResponse.containsKey('data')) 
            ? backendResponse['data'] 
            : backendResponse;
        
        if (actualData != null) {
          // Check for different possible token field names
          final token = actualData['accessToken'] ?? 
                       actualData['access_token'] ?? 
                       actualData['token'];
          
          if (token != null) {
            await ApiService.saveToken(token);
          }
          
          // Store user role information - try multiple paths
          final user = actualData['user'] ?? backendResponse['user'];
          bool roleSaved = false;
          
          if (user != null && user['user_role'] != null) {
            final userRole = user['user_role'];
            final roleIdValue = userRole['role_id'];
            final roleName = userRole['name'] ?? '';
            
            // Save role_id and role name if role_id exists
            if (roleIdValue != null) {
              final roleIdInt = roleIdValue is int 
                  ? roleIdValue 
                  : (int.tryParse(roleIdValue.toString()) ?? 3);
              await ApiService.saveUserRole(roleIdInt, roleName);
              roleSaved = true;
            }
          }
          
          // Fallback: If role wasn't found in response, use the roleId from login parameter
          if (!roleSaved && roleId != null) {
            final roleName = roleId == 1 ? 'admin' : (roleId == 3 ? 'customer' : 'user');
            await ApiService.saveUserRole(roleId, roleName);
          }
        }
        return actualData ?? backendResponse;
      } else {
        throw Exception(response['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // 1. Get Firebase UID from Google Sign-In
    // 2. Call signIn with provider: "google" and uid: firebaseUID
    // For now, throw error to indicate it needs implementation
    throw UnimplementedError('Please implement Google Sign-In first. You need to integrate Firebase Auth and get the UID, then call signIn with provider: "google"');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await ApiService.post(
        '$baseUrl/auth/logout',
        {},
        requireAuth: true,
      );
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout error: $e');
    } finally {
      await ApiService.removeToken();
    }
  }

  // 1.1 Check Email - Get user role by email
  Future<int?> checkEmail(String email) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/check-email',
        {'email': email},
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Backend returns role_id as number
        if (data is int) {
          return data;
        } else if (data is Map && data['data'] != null) {
          return int.tryParse(data['data'].toString());
        } else {
          return int.tryParse(data.toString());
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to check email');
      }
    } catch (e) {
      throw Exception('Check email error: ${e.toString()}');
    }
  }

  // 1.4 Generate OTP
  Future<void> generateOTP(String emailOrPhone) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/generate-otp',
        {'emailOrPhone': emailOrPhone},
        requireAuth: false,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to generate OTP');
      }
    } catch (e) {
      throw Exception('Generate OTP error: ${e.toString()}');
    }
  }

  // Phone OTP verification (legacy method - kept for compatibility)
  Future<void> verifyPhoneNumber({
    required String phone,
    required Function(String) codeSent,
    required Function(Map<String, dynamic>?) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await generateOTP(phone);
      codeSent(phone); // Use phone as verification ID
    } catch (e) {
      onError(e.toString());
    }
  }

  // 1.5 Verify OTP
  Future<Map<String, dynamic>?> verifyOTP({
    required String emailOrPhone,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/verify-otp',
        {
          'emailOrPhone': emailOrPhone,
          'otp': otp,
        },
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final backendResponse = response['data'];
        
        // The backend returns: { statusCode: 200, data: "OTP verified", message: "...", success: true }
        // Extract the actual data from the backend response
        dynamic actualData;
        if (backendResponse is Map<String, dynamic>) {
          actualData = backendResponse['data'] ?? backendResponse;
          
          // Check for accessToken only if the data is a Map (not a string)
          if (actualData is Map<String, dynamic>) {
            final token = actualData['accessToken'] ?? 
                         actualData['access_token'] ?? 
                         actualData['token'];
            
            // Only save token if it's a String (not an int like statusCode)
            if (token != null && token is String) {
              await ApiService.saveToken(token);
            }
          }
        } else {
          actualData = backendResponse;
        }
        
        // Return a proper Map structure
        if (actualData is Map<String, dynamic>) {
          return actualData;
        } else {
          return {'message': actualData?.toString() ?? 'OTP verified', 'verified': true};
        }
      } else {
        throw Exception(response['error'] ?? 'OTP verification failed');
      }
    } catch (e) {
      throw Exception('OTP verification error: ${e.toString()}');
    }
  }

  // Sign in with OTP (legacy method - kept for compatibility)
  Future<Map<String, dynamic>?> signInWithOTP(String verificationId, String smsCode) async {
    return await verifyOTP(emailOrPhone: verificationId, otp: smsCode);
  }
  
  // 1.6 Reset Password
  Future<void> resetPassword({
    required String emailOrPhone,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/reset-password',
        {
          'emailOrPhone': emailOrPhone,
          'newPassword': newPassword,
        },
        requireAuth: false,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Reset password error: ${e.toString()}');
    }
  }

  // 1.7 Change Password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/change-password',
        {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        requireAuth: true,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Change password error: ${e.toString()}');
    }
  }

  // 1.8 Update Account Details - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> updateAccountDetails({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    File? profileImage, // Changed from String? to File? for multipart upload
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (firstName != null) fields['first_name'] = firstName;
      if (lastName != null) fields['last_name'] = lastName;
      if (phoneNumber != null) fields['phone_number'] = phoneNumber;
      
      final files = profileImage != null ? {'profile_image': profileImage} : null;
      
      final response = await ApiService.patchMultipart(
        '$baseUrl/auth/update-account',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update account');
      }
    } catch (e) {
      throw Exception('Update account error: ${e.toString()}');
    }
  }

  // 1.9 Update Cover Image - API endpoint requires multipart/form-data
  Future<Map<String, dynamic>?> updateCoverImage(File coverImage) async {
    try {
      final files = {'cover_image': coverImage};
      
      final response = await ApiService.patchMultipart(
        '$baseUrl/auth/update-cover-image',
        {},
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data'] as Map);
        }
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to update cover image');
      }
    } catch (e) {
      throw Exception('Update cover image error: ${e.toString()}');
    }
  }

  // 1.10 Create FCM Token
  Future<void> createFCMToken({
    required String userId,
    required String fcmToken,
    required String deviceType, // "android" or "ios"
    required String deviceId,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/auth/create-fcm-token',
        {
          'user_id': userId,
          'fcm_token': fcmToken,
          'device_type': deviceType,
          'device_id': deviceId,
        },
        requireAuth: true,
      );
      
      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to create FCM token');
      }
    } catch (e) {
      throw Exception('Create FCM token error: ${e.toString()}');
    }
  }
  
  // Refresh access token. Body: { "refreshToken" } or cookie.
  Future<Map<String, dynamic>?> refreshToken({String? refreshToken}) async {
    try {
      final body = refreshToken != null && refreshToken.isNotEmpty
          ? <String, dynamic>{'refreshToken': refreshToken}
          : <String, dynamic>{};
      final response = await ApiService.post(
        '$baseUrl/auth/refresh-token',
        body,
        requireAuth: false,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) {
          final token = data['accessToken'] ?? data['access_token'] ?? data['token'];
          if (token != null) await ApiService.saveToken(token.toString());
        }
        return response['data'] is Map ? Map<String, dynamic>.from(response['data'] as Map) : null;
      }
      throw Exception(response['error'] ?? 'Failed to refresh token');
    } catch (e) {
      throw Exception('Refresh token error: ${e.toString()}');
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/auth/current-user',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get user');
      }
    } catch (e) {
      throw Exception('Get user error: ${e.toString()}');
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
