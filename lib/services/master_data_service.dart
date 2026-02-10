import 'dart:io';
import 'api_service.dart';
import '../config/app_config.dart';

class MasterDataService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // Get all countries
  Future<List<dynamic>> getAllCountries() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-country',
        requireAuth: false,
      );
      
      // Debug: Print response structure
      print('Countries API Response: $response');
      
      if (response['success'] == true) {
        final data = response['data'];
        
        // Handle different response structures
        // Backend returns: { statusCode, data: [...], message, success }
        // ApiService wraps it: { success: true, data: { statusCode, data: [...], message, success } }
        
        if (data is List) {
          return data;
        } else if (data is Map) {
          // Check for nested data structure from ApiResponse
          if (data['data'] is List) {
            return data['data'];
          } else if (data['countries'] is List) {
            return data['countries'];
          }
          // If data is a Map but doesn't have 'data' or 'countries', log it
          print('Unexpected response structure: $data');
        }
        
        // If we get here, the structure is unexpected
        print('No countries found in response. Response structure: ${response.toString()}');
        return [];
      } else {
        final errorMsg = response['error'] ?? 'Failed to get countries';
        print('Countries API Error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Get countries exception: ${e.toString()}');
      // Provide more detailed error message
      if (e.toString().contains('Failed to fetch') || 
          e.toString().contains('NetworkError') ||
          e.toString().contains('Connection refused')) {
        throw Exception('Cannot connect to server. Please ensure the backend server is running on https://outbox.nablean.com');
      }
      throw Exception('Get countries error: ${e.toString()}');
    }
  }
  
  // Get cities by country ID
  Future<List<dynamic>> getCitiesByCountry(String countryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-city/$countryId',
        requireAuth: false,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        // Handle different response structures
        // Backend returns: { statusCode, data: [...], message, success }
        // ApiService wraps it: { success: true, data: { statusCode, data: [...], message, success } }
        if (data is List) {
          return data;
        } else if (data is Map) {
          // Check for nested data structure from ApiResponse
          if (data['data'] is List) {
            return data['data'];
          } else if (data['cities'] is List) {
            return data['cities'];
          }
        }
        return [];
      } else {
        throw Exception(response['error'] ?? 'Failed to get cities');
      }
    } catch (e) {
      throw Exception('Get cities error: ${e.toString()}');
    }
  }

  // Helper method to extract data from response
  List<dynamic> _extractListFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Map<String, dynamic>? _extractMapFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return null;
  }

  // 3.1 Get Latest Terms & Policy
  Future<Map<String, dynamic>?> getLatestTerms() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-latest-terms',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get terms');
      }
    } catch (e) {
      throw Exception('Get terms error: ${e.toString()}');
    }
  }

  // Get Latest Privacy Policy
  Future<Map<String, dynamic>?> getLatestPrivacy() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-latest-privacy',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get privacy policy');
      }
    } catch (e) {
      throw Exception('Get privacy policy error: ${e.toString()}');
    }
  }

  // 3.3 Get All Tenures
  Future<List<dynamic>> getAllTenures() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-tenure',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get tenures');
      }
    } catch (e) {
      throw Exception('Get tenures error: ${e.toString()}');
    }
  }

  // 3.7 Get All Tax Masters
  Future<List<dynamic>> getAllTaxMasters({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/master/get-all-tax-master',
        {
          'page': page,
          'limit': limit,
        },
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get tax masters');
      }
    } catch (e) {
      throw Exception('Get tax masters error: ${e.toString()}');
    }
  }

  /// POST /api/v1/master/get-all-location-master
  /// Body: { "page": 1, "limit": 100 }. Headers: Authorization Bearer JWT, Content-Type application/json.
  /// Parses locations from response.data.allLocationMasters (CRITICAL).
  Future<List<dynamic>> getAllLocationMasters({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    try {
      final payload = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) payload['search'] = search;

      final response = await ApiService.post(
        '$baseUrl/master/get-all-location-master',
        payload,
        requireAuth: true,
      );

      final statusCode = response['statusCode'];
      if (statusCode == 401) {
        print('Location Master API: 401 Unauthorized (JWT expired or invalid).');
        throw Exception('Session expired. Please log in again.');
      }
      if (statusCode == 404) {
        print('Location Master API: 404 Endpoint not found. Check URL: /master/get-all-location-master');
        throw Exception('Location service not found. Please contact support.');
      }
      if (statusCode != null && statusCode >= 500) {
        print('Location Master API: $statusCode Server error.');
        throw Exception('Server error. Please try again later.');
      }

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Failed to get locations');
      }

      final list = _extractLocationMastersFromResponse(response);
      print('Location Master API: parsed ${list.length} location(s).');

      if (list.isEmpty) {
        final data = response['data'];
        if (data != null) {
          print('Location Master API: response.data type=${data.runtimeType}. '
              'If Map, keys: ${data is Map ? (data as Map).keys.toList() : "n/a"}');
        } else {
          print('Location Master API: response.data is null.');
        }
        print('No Location Masters found. Creating a default one.');
        try {
          final created = await createDefaultLocationMaster();
          if (created != null) {
            final refetch = await ApiService.post(
              '$baseUrl/master/get-all-location-master',
              {'page': 1, 'limit': 100},
              requireAuth: true,
            );
            if (refetch['success'] == true) {
              final refetched = _extractLocationMastersFromResponse(refetch);
              print('Location Master: re-fetched ${refetched.length} location(s) after creating default.');
              return refetched;
            }
          }
        } catch (e) {
          print('Location Master: failed to create default: $e');
        }
        return [];
      }

      return list;
    } catch (e) {
      throw Exception('Get locations error: ${e.toString()}');
    }
  }

  /// Parse locations: prefer response.data.allLocationMasters; fallback to response.data (List) or nested data.data.allLocationMasters.
  /// Backend may return { statusCode, data: { allLocationMasters: [...] } } so list is at data.data.allLocationMasters.
  List<dynamic> _extractLocationMastersFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    // Backend may return data as array directly: { success: true, data: [ ... ] }
    if (data is List) {
      return data;
    }
    if (data is! Map) return [];
    final list = data['allLocationMasters'];
    if (list is List) return list;
    if (data['data'] is List) return data['data'];
    if (data['locations'] is List) return data['locations'];
    // Nested: { statusCode, data: { allLocationMasters: [...] } } → response.data.data.allLocationMasters
    final inner = data['data'];
    if (inner is Map) {
      if (inner['allLocationMasters'] is List) return inner['allLocationMasters'];
      if (inner['data'] is List) return inner['data'];
    }
    return [];
  }

  // 3.11 Get Locations by Country and City
  Future<List<dynamic>> getLocationsByCountryCity({
    required String countryId,
    required String cityId,
  }) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-location-by-country-city',
        requireAuth: false,
        queryParams: {
          'country': countryId,
          'city': cityId,
        },
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get locations');
      }
    } catch (e) {
      throw Exception('Get locations by country/city error: ${e.toString()}');
    }
  }

  // Get All Sessions
  Future<List<dynamic>> getAllSessions() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-sessions',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get sessions');
      }
    } catch (e) {
      throw Exception('Get sessions error: ${e.toString()}');
    }
  }

  // Get Session by ID
  Future<Map<String, dynamic>?> getSessionById(String sessionId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-session-by-id/$sessionId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get session');
      }
    } catch (e) {
      throw Exception('Get session error: ${e.toString()}');
    }
  }

  // Get Sessions by Category ID
  Future<List<dynamic>> getSessionsByCategoryId(String categoryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-session-by-category-id/$categoryId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get sessions');
      }
    } catch (e) {
      throw Exception('Get sessions by category error: ${e.toString()}');
    }
  }

  // Get All Categories
  Future<List<dynamic>> getAllCategories() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-categories',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get categories');
      }
    } catch (e) {
      throw Exception('Get categories error: ${e.toString()}');
    }
  }

  // Get Category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-category-by-id/$categoryId',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractMapFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get category');
      }
    } catch (e) {
      throw Exception('Get category error: ${e.toString()}');
    }
  }

  // Get All Customer Services
  // Note: The backend route /user/get-all-services is commented out
  // This endpoint may not be available. Returning empty list as fallback.
  Future<List<dynamic>> getAllCustomerServices() async {
    try {
      // Try the original endpoint first (in case it gets uncommented)
      final response = await ApiService.get(
        '$baseUrl/user/get-all-services',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        // If endpoint doesn't exist, return empty list instead of throwing error
        print('Warning: get-all-services endpoint not available. Returning empty list.');
        return [];
      }
    } catch (e) {
      // If endpoint is not found (404) or route doesn't exist, return empty list
      if (e.toString().contains('Cannot GET') || 
          e.toString().contains('404') ||
          e.toString().contains('not found')) {
        print('Warning: Customer services endpoint not available. The route may be commented out in the backend.');
        return [];
      }
      // For other errors, still throw to maintain error visibility
      throw Exception('Get services error: ${e.toString()}');
    }
  }

  // Get All Roles
  Future<List<dynamic>> getAllRoles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/master/get-all-role',
        {
          'page': page,
          'limit': limit,
        },
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get roles');
      }
    } catch (e) {
      throw Exception('Get roles error: ${e.toString()}');
    }
  }

  // Get All Active Roles
  Future<List<dynamic>> getAllActiveRoles() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-all-active-role',
        requireAuth: false,
      );
      if (response['success'] == true) {
        return _extractListFromResponse(response);
      } else {
        throw Exception(response['error'] ?? 'Failed to get active roles');
      }
    } catch (e) {
      throw Exception('Get active roles error: ${e.toString()}');
    }
  }

  /// POST /master/create-location-master
  /// Body: streetName, country, city, landmark?, is_active?, location: [latitude, longitude]
  Future<Map<String, dynamic>?> createLocationMaster({
    required String streetName,
    required String country,
    required String city,
    String? landmark,
    bool isActive = true,
    required List<double> location,
  }) async {
    try {
      final payload = <String, dynamic>{
        'streetName': streetName,
        'country': country,
        'city': city,
        'is_active': isActive,
        'location': location.length >= 2 ? location : [0.0, 0.0],
      };
      if (landmark != null && landmark.isNotEmpty) payload['landmark'] = landmark;

      final response = await ApiService.post(
        '$baseUrl/master/create-location-master',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        // Backend may put created document in data, data.data, data.location, data.result, etc.
        Map<String, dynamic>? doc;
        if (data is Map<String, dynamic> && (data['_id'] != null || data['id'] != null)) {
          doc = data;
        } else if (data is Map && data['data'] is Map) {
          final d = data['data'] as Map;
          doc = Map<String, dynamic>.from(d);
        }
        if (doc == null && data is Map) {
          for (final key in ['location', 'result', 'createdLocation', 'locationMaster']) {
            final v = data[key];
            if (v is Map && (v['_id'] != null || v['id'] != null)) {
              doc = Map<String, dynamic>.from(v);
              break;
            }
          }
        }
        return doc;
      } else {
        final statusCode = response['statusCode'];
        final error = response['error'] ?? response['data']?['message'] ?? response['data']?['error'] ?? 'Failed to create location';
        if (statusCode == 400) {
          print('Location Master create 400: $error. Payload sent: streetName, country (id), city (id), landmark?, location.');
        }
        throw Exception(error.toString());
      }
    } catch (e) {
      throw Exception('Create location error: ${e.toString()}');
    }
  }

  /// Create a default Location Master when none exist.
  /// Backend expects country and city as ObjectIds (from country/city masters), not names.
  /// Fetches first available country and city; if none exist, skips create to avoid 400.
  Future<Map<String, dynamic>?> createDefaultLocationMaster() async {
    try {
      final countries = await getAllCountries();
      if (countries.isEmpty) {
        print('Location Master: no countries in master — cannot auto-create default location.');
        return null;
      }
      final firstCountry = countries.first;
      final countryId = (firstCountry['_id'] ?? firstCountry['id'] ?? '').toString();
      if (countryId.isEmpty) {
        print('Location Master: country has no _id — cannot auto-create.');
        return null;
      }
      final cities = await getCitiesByCountry(countryId);
      if (cities.isEmpty) {
        print('Location Master: no cities for country — cannot auto-create default location.');
        return null;
      }
      final firstCity = cities.first;
      final cityId = (firstCity['_id'] ?? firstCity['id'] ?? '').toString();
      if (cityId.isEmpty) {
        print('Location Master: city has no _id — cannot auto-create.');
        return null;
      }
      final created = await createLocationMaster(
        streetName: 'Auto Generated',
        country: countryId,
        city: cityId,
        landmark: 'Auto Generated',
        isActive: true,
        location: [0.0, 0.0],
      );
      if (created != null) {
        print('Location Master: default location created with _id=${created['_id'] ?? created['id']}');
      }
      return created;
    } catch (e) {
      print('Location Master: createDefaultLocationMaster failed: $e');
      return null;
    }
  }

  // 3.14 Create Category (multipart). Backend expects cName (not name).
  Future<Map<String, dynamic>?> createCategory({
    required String name,
    required String description,
    bool isActive = true,
    File? image,
  }) async {
    try {
      final fields = <String, String>{
        'cName': name,
        'name': name,
        'description': description,
        'isActive': isActive.toString(),
      };
      final response = await ApiService.postMultipart(
        '$baseUrl/master/create-category',
        fields,
        files: image != null ? {'image': image} : null,
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      } else {
        throw Exception(response['error'] ?? 'Failed to create category');
      }
    } catch (e) {
      throw Exception('Create category error: ${e.toString()}');
    }
  }

  /// PUT /master/update-location-master/:id
  Future<Map<String, dynamic>?> updateLocationMaster({
    required String id,
    String? streetName,
    String? country,
    String? city,
    String? landmark,
    bool? isActive,
    List<double>? location,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (streetName != null) payload['streetName'] = streetName;
      if (country != null) payload['country'] = country;
      if (city != null) payload['city'] = city;
      if (landmark != null) payload['landmark'] = landmark;
      if (isActive != null) payload['is_active'] = isActive;
      if (location != null && location.length >= 2) payload['location'] = location;

      final response = await ApiService.put(
        '$baseUrl/master/update-location-master/$id',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to update location');
    } catch (e) {
      throw Exception('Update location error: ${e.toString()}');
    }
  }

  /// GET /master/get-location-master/:id
  Future<Map<String, dynamic>?> getLocationMasterById(String id) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/master/get-location-master/$id',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get location');
    } catch (e) {
      throw Exception('Get location by ID error: ${e.toString()}');
    }
  }

  /// DELETE /master/delete-location-master-by-id/:id
  Future<Map<String, dynamic>?> deleteLocationMaster(String id) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/master/delete-location-master-by-id/$id',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete location');
    } catch (e) {
      throw Exception('Delete location error: ${e.toString()}');
    }
  }

  /// PUT /master/update-category/:id (multipart)
  Future<Map<String, dynamic>?> updateCategory({
    required String id,
    String? name,
    String? description,
    bool? isActive,
    File? image,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (name != null) fields['cName'] = name;
      if (description != null) fields['description'] = description;
      if (isActive != null) fields['isActive'] = isActive.toString();

      final response = await ApiService.putMultipart(
        '$baseUrl/master/update-category/$id',
        fields,
        files: image != null ? {'image': image} : null,
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to update category');
    } catch (e) {
      throw Exception('Update category error: ${e.toString()}');
    }
  }

  /// DELETE /master/delete-category/:id
  Future<Map<String, dynamic>?> deleteCategory(String id) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/master/delete-category/$id',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete category');
    } catch (e) {
      throw Exception('Delete category error: ${e.toString()}');
    }
  }
}

