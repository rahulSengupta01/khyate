import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class AdminService {
  /// All admin endpoints use [AppConfig.baseUrl].
  static String get _baseUrl => AppConfig.baseUrl;

  // 6.1 Create Promo Code — POST multipart
  Future<Map<String, dynamic>?> createPromoCode({
    File? image,
    String? imageUrl,
    required String code,
    required String discountType,
    required double discountValue,
    required int maxUses,
    required String termsAndConditions,
    String? description,
    bool? isActive,
    bool? isValidationDate,
    String? startDate,
    String? endDate,
    int? applyOfferAfterOrders,
    double? minOrderAmount,
    double? maxDiscountAmount,
  }) async {
    try {
      final type = discountType.trim().isEmpty
          ? 'Percentage'
          : (discountType.trim().toLowerCase() == 'percentage' ? 'Percentage' : discountType.trim());
      final fields = <String, dynamic>{
        'code': code,
        'discountType': type,
        'discountValue': discountValue.toString(),
        'maxUses': maxUses.toString(),
        'termsAndConditions': termsAndConditions,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive.toString(),
        if (isValidationDate != null) 'is_validation_date': isValidationDate.toString(),
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        if (applyOfferAfterOrders != null) 'apply_offer_after_orders': applyOfferAfterOrders.toString(),
        if (minOrderAmount != null) 'minOrderAmount': minOrderAmount.toString(),
        if (maxDiscountAmount != null) 'maxDiscountAmount': maxDiscountAmount.toString(),
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$_baseUrl/admin/create-promo-code',
        fields,
        files: files,
        requireAuth: true,
      );

      final success = response['success'] == true;
      if (success) {
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      }
      final err = response['error'];
      final msg = err is String ? err : err?.toString() ?? 'Failed to create promo code';
      final statusCode = response['statusCode'];
      throw Exception(statusCode != null ? '$msg (HTTP $statusCode)' : msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Create promo code error: ${e.toString()}');
    }
  }
  
  // 6.2 Update Promo Code
  Future<Map<String, dynamic>?> updatePromoCode({
    required String promoCodeId,
    File? image,
    String? imageUrl,
    String? code,
    String? discountType,
    double? discountValue,
    String? description,
    bool? isActive,
    bool? isValidationDate,
    String? startDate,
    String? endDate,
    int? applyOfferAfterOrders,
    double? minOrderAmount,
    double? maxDiscountAmount,
    int? maxUses,
    String? termsAndConditions,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (code != null) fields['code'] = code;
      if (discountType != null) {
        final t = discountType!.trim();
        fields['discountType'] = t.isEmpty ? 'Percentage' : (t.toLowerCase() == 'percentage' ? 'Percentage' : t);
      }
      if (discountValue != null) fields['discountValue'] = discountValue.toString();
      if (description != null) fields['description'] = description;
      if (isActive != null) fields['isActive'] = isActive.toString();
      if (isValidationDate != null) fields['is_validation_date'] = isValidationDate.toString();
      if (startDate != null) fields['startDate'] = startDate;
      if (endDate != null) fields['endDate'] = endDate;
      if (applyOfferAfterOrders != null) fields['apply_offer_after_orders'] = applyOfferAfterOrders.toString();
      if (minOrderAmount != null) fields['minOrderAmount'] = minOrderAmount.toString();
      if (maxDiscountAmount != null) fields['maxDiscountAmount'] = maxDiscountAmount.toString();
      if (maxUses != null) fields['maxUses'] = maxUses.toString();
      if (termsAndConditions != null) fields['termsAndConditions'] = termsAndConditions;
      if (imageUrl != null && imageUrl.isNotEmpty) fields['imageUrl'] = imageUrl;
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$_baseUrl/admin/update-promo-code/$promoCodeId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        final err = response['error'] ?? 'Failed to update promo code';
        final code = response['statusCode'];
        throw Exception(code != null ? '$err (HTTP $code)' : err);
      }
    } catch (e) {
      throw Exception('Update promo code error: ${e.toString()}');
    }
  }
  
  // 6.3 Get Promo Code by ID
  Future<Map<String, dynamic>?> getPromoCodeById({
    required String promoCodeId,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-promo-code-by-id/$promoCodeId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get promo code');
      }
    } catch (e) {
      throw Exception('Get promo code by ID error: ${e.toString()}');
    }
  }
  
  // 6.4 List (get all) promo codes
  Future<Map<String, dynamic>> getAllPromoCodes() async {
    const endpointSuffix = '/admin/get-all-promo-codes';
    final endpoint = '$_baseUrl$endpointSuffix';
    Map<String, dynamic> response = await ApiService.post(endpoint, <String, dynamic>{}, requireAuth: true);
    final statusCode = response['statusCode'];
    if (response['success'] != true && statusCode == 405) {
      response = await ApiService.get(endpoint, requireAuth: true);
    }
    if (response['success'] != true) {
      final err = response['error'];
      final msg = err is String ? err : err?.toString() ?? 'Failed to load promo codes';
      final code = response['statusCode'];
      throw Exception(code != null ? '$msg (HTTP $code)' : msg);
    }
    dynamic raw = response['data'];
    if (raw == null) return <String, dynamic>{'promoCodes': <dynamic>[]};
    if (raw is Map && raw['data'] != null) raw = raw['data'];
    if (raw is List) return <String, dynamic>{'promoCodes': List<dynamic>.from(raw)};
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw as Map);
      final inner = map['data'];
      if (inner is Map && map['promoCodes'] == null && inner['promoCodes'] != null) {
        return <String, dynamic>{'promoCodes': List<dynamic>.from(inner['promoCodes'] as List)};
      }
      if (map['promoCodes'] is List) return map;
      if (inner is List) return <String, dynamic>{'promoCodes': List<dynamic>.from(inner)};
      if (map['data'] is List) return <String, dynamic>{'promoCodes': List<dynamic>.from(map['data'] as List)};
      return map;
    }
    return <String, dynamic>{'promoCodes': <dynamic>[]};
  }
  
  // 6.5 Delete Promo Code
  Future<void> deletePromoCode({required String promoCodeId}) async {
    if (promoCodeId.trim().isEmpty) {
      throw Exception('Promo code ID is required');
    }
    try {
      final response = await ApiService.delete(
        '$_baseUrl/admin/delete-promo-code/$promoCodeId',
        requireAuth: true,
      );
      if (response['success'] == true) return;
      final err = response['error'];
      final msg = err is String ? err : err?.toString() ?? 'Failed to delete promo code';
      final code = response['statusCode'];
      throw Exception(code != null ? '$msg (HTTP $code)' : msg);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Delete promo code error: ${e.toString()}');
    }
  }
  
  // 6.6 Get All Subservice Rating Reviews
  Future<Map<String, dynamic>?> getAllSubserviceRatingReviews({
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-all-subservice-rating-review/$subServiceId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get subservice rating reviews');
      }
    } catch (e) {
      throw Exception('Get subservice rating reviews error: ${e.toString()}');
    }
  }
  
  // 6.7 Get All Orders
  Future<Map<String, dynamic>?> getAllOrders() async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-all-orders',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get all orders');
      }
    } catch (e) {
      throw Exception('Get all orders error: ${e.toString()}');
    }
  }
  
  // 6.8 Get Dashboard Details
  Future<Map<String, dynamic>?> getDashboardDetails() async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-dashboard-details',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get dashboard details');
      }
    } catch (e) {
      throw Exception('Get dashboard details error: ${e.toString()}');
    }
  }
  
  // 6.9 Get Month Wise Data
  Future<Map<String, dynamic>?> getMonthWiseData({
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      
      final response = await ApiService.get(
        '$_baseUrl/admin/get-month-wise-data',
        requireAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get month wise data');
      }
    } catch (e) {
      throw Exception('Get month wise data error: ${e.toString()}');
    }
  }
  
  // 6.10 Get Planner Dashboard
  Future<Map<String, dynamic>?> getPlannerDashboard({
    required String bookingDate,
    String? subServiceId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'bookingDate': bookingDate,
        if (subServiceId != null) 'subServiceId': subServiceId,
      };
      
      final response = await ApiService.post(
        '$_baseUrl/admin/get-planner-dashboard',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get planner dashboard');
      }
    } catch (e) {
      throw Exception('Get planner dashboard error: ${e.toString()}');
    }
  }
  
  // 6.11 Get Available Groomers
  Future<Map<String, dynamic>?> getAvailableGroomers({
    required String groomerId,
    required String timeSlotId,
    required String date,
  }) async {
    try {
      final response = await ApiService.post(
        '$_baseUrl/admin/get-all-available-groomers',
        {
          'groomerId': groomerId,
          'timeSlotId': timeSlotId,
          'date': date,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get available groomers');
      }
    } catch (e) {
      throw Exception('Get available groomers error: ${e.toString()}');
    }
  }
  
  // 6.12 Get Available Groomers for Booking
  Future<Map<String, dynamic>?> getAvailableGroomersForBooking({
    required String date,
    required String timeslot,
    required String subServiceId,
  }) async {
    try {
      final response = await ApiService.post(
        '$_baseUrl/admin/get-all-available-groomers-booking',
        {
          'date': date,
          'timeslot': timeslot,
          'subServiceId': subServiceId,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get available groomers for booking');
      }
    } catch (e) {
      throw Exception('Get available groomers for booking error: ${e.toString()}');
    }
  }
  
  // 6.13 Create Article
  Future<Map<String, dynamic>?> createArticle({
    File? image,
    String? imageUrl,
    required String title,
    String? description,
  }) async {
    try {
      final fields = <String, dynamic>{
        'title': title,
        if (description != null) 'description': description,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      };
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.postMultipart(
        '$_baseUrl/admin/create-artical',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create article');
      }
    } catch (e) {
      throw Exception('Create article error: ${e.toString()}');
    }
  }
  
  // 6.14 Get All Articles
  Future<Map<String, dynamic>?> getAllArticles() async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-all-articals',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get all articles');
      }
    } catch (e) {
      throw Exception('Get all articles error: ${e.toString()}');
    }
  }
  
  // 6.15 Get Article by ID
  Future<Map<String, dynamic>?> getArticleById({
    required String articleId,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/admin/get-artical/$articleId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to get article');
      }
    } catch (e) {
      throw Exception('Get article by ID error: ${e.toString()}');
    }
  }
  
  // 6.16 Update Article
  Future<Map<String, dynamic>?> updateArticle({
    required String articleId,
    File? image,
    String? imageUrl,
    String? title,
    String? description,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (imageUrl != null && imageUrl.isNotEmpty) fields['imageUrl'] = imageUrl;
      
      final files = image != null ? {'image': image} : null;
      
      final response = await ApiService.putMultipart(
        '$_baseUrl/admin/update-artical/$articleId',
        fields,
        files: files,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update article');
      }
    } catch (e) {
      throw Exception('Update article error: ${e.toString()}');
    }
  }
  
  // 6.17 Delete Article
  Future<Map<String, dynamic>?> deleteArticle({
    required String articleId,
  }) async {
    try {
      final response = await ApiService.delete(
        '$_baseUrl/admin/delete-artical/$articleId',
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to delete article');
      }
    } catch (e) {
      throw Exception('Delete article error: ${e.toString()}');
    }
  }
}

