import 'api_service.dart';
import '../config/app_config.dart';

class CartService {
  static const String baseUrl = AppConfig.baseUrl;

  /// POST /cart/create-cart. Body: subServiceId, quantity?, timeslotId, bookingDate, petDetails
  Future<Map<String, dynamic>?> createCart({
    required String subServiceId,
    int? quantity,
    required String timeslotId,
    required String bookingDate,
    required Map<String, dynamic> petDetails,
  }) async {
    try {
      final payload = <String, dynamic>{
        'subServiceId': subServiceId,
        'timeslotId': timeslotId,
        'bookingDate': bookingDate,
        'petDetails': petDetails,
      };
      if (quantity != null) payload['quantity'] = quantity;

      final response = await ApiService.post(
        '$baseUrl/cart/create-cart',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to create cart');
    } catch (e) {
      throw Exception('Create cart error: ${e.toString()}');
    }
  }

  /// GET /cart/get-all-cart
  Future<List<dynamic>> getAllCart() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/cart/get-all-cart',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['cart'] is List) return data['cart'] as List;
        if (data is Map && data['items'] is List) return data['items'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get cart');
    } catch (e) {
      throw Exception('Get all cart error: ${e.toString()}');
    }
  }

  /// DELETE /cart/delete-cart-item/:cartId
  Future<Map<String, dynamic>?> deleteCartItem(String cartId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/cart/delete-cart-item/$cartId',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete cart item');
    } catch (e) {
      throw Exception('Delete cart item error: ${e.toString()}');
    }
  }
  
  // 2.14 Calculate Cart Total
  Future<Map<String, dynamic>?> calculateCartTotal({
    required List<String> cartItems,
    String? promoCode,
  }) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/user/cart-total-price-calculate',
        {
          'cartItems': cartItems,
          if (promoCode != null) 'promoCode': promoCode,
        },
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        final data = response['data'];
        return data is Map ? data : (data['data'] as Map?);
      } else {
        throw Exception(response['error'] ?? 'Failed to calculate cart total');
      }
    } catch (e) {
      throw Exception('Calculate cart total error: ${e.toString()}');
    }
  }
}

