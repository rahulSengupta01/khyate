import 'api_service.dart';
import '../config/app_config.dart';

class OrderService {
  static const String baseUrl = AppConfig.baseUrl;

  /// POST /order/create-order. Body: cartItems, addressId, paymentMethod, promoCode?
  Future<Map<String, dynamic>?> createOrder({
    required List<dynamic> cartItems,
    required String addressId,
    required String paymentMethod,
    String? promoCode,
  }) async {
    try {
      final payload = <String, dynamic>{
        'cartItems': cartItems,
        'addressId': addressId,
        'paymentMethod': paymentMethod,
      };
      if (promoCode != null && promoCode.isNotEmpty) payload['promoCode'] = promoCode;

      final response = await ApiService.post(
        '$baseUrl/order/create-order',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to create order');
    } catch (e) {
      throw Exception('Create order error: ${e.toString()}');
    }
  }

  /// PUT /order/update-order. Body: orderId, status?, notes?
  Future<Map<String, dynamic>?> updateOrder({
    required String orderId,
    String? status,
    String? notes,
  }) async {
    try {
      final payload = <String, dynamic>{'orderId': orderId};
      if (status != null) payload['status'] = status;
      if (notes != null) payload['notes'] = notes;

      final response = await ApiService.put(
        '$baseUrl/order/update-order',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to update order');
    } catch (e) {
      throw Exception('Update order error: ${e.toString()}');
    }
  }

  /// GET /order/get-all-order (user context)
  Future<List<dynamic>> getAllOrders() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/order/get-all-order',
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

  /// GET /order/get-order-detail/:orderId
  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/order/get-order-detail/$orderId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get order detail');
    } catch (e) {
      throw Exception('Get order detail error: ${e.toString()}');
    }
  }

  /// POST /payment/create-payment. Body: orderId, amount, paymentMethod, transactionId?
  Future<Map<String, dynamic>?> createPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      };
      if (transactionId != null && transactionId.isNotEmpty) payload['transactionId'] = transactionId;

      final response = await ApiService.post(
        '$baseUrl/payment/create-payment',
        payload,
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to create payment');
    } catch (e) {
      throw Exception('Create payment error: ${e.toString()}');
    }
  }
}
