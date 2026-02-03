import 'api_service.dart';
import '../config/app_config.dart';

class BookingService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // 13.1 Create Manual Booking
  Future<Map<String, dynamic>?> createManualBooking({
    required String subServiceId,
    required String timeslotId,
    required String bookingDate,
    required String groomerId,
    required String addressId,
    required Map<String, dynamic> petDetails,
  }) async {
    try {
      final payload = {
        'subServiceId': subServiceId,
        'timeslotId': timeslotId,
        'bookingDate': bookingDate,
        'groomerId': groomerId,
        'addressId': addressId,
        'petDetails': petDetails,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/create-manual-booking',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create manual booking');
      }
    } catch (e) {
      throw Exception('Create manual booking error: ${e.toString()}');
    }
  }
  
  // 13.2 Update Manual Booking
  Future<Map<String, dynamic>?> updateBooking({
    required String bookingId,
    String? bookingDate,
    String? timeslotId,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (bookingDate != null) payload['bookingDate'] = bookingDate;
      if (timeslotId != null) payload['timeslotId'] = timeslotId;
      
      final response = await ApiService.put(
        '$baseUrl/booking/update-booking/$bookingId',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to update booking');
      }
    } catch (e) {
      throw Exception('Update booking error: ${e.toString()}');
    }
  }
  
  // 13.3 Create Subscription Booking (already exists but update to match API)
  Future<Map<String, dynamic>?> createSubscriptionBooking({
    required String subscriptionId,
    String? paymentMethod,
    String? promoCode,
  }) async {
    try {
      final payload = {
        'subscriptionId': subscriptionId,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (promoCode != null) 'promoCode': promoCode,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/subscribe',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to create subscription booking');
      }
    } catch (e) {
      throw Exception('Create subscription booking error: ${e.toString()}');
    }
  }
  
  // 13.4 Cancel Subscription Booking
  Future<Map<String, dynamic>?> cancelSubscriptionBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      final payload = {
        'bookingId': bookingId,
        if (reason != null) 'reason': reason,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/cancel-subscribe',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to cancel subscription booking');
      }
    } catch (e) {
      throw Exception('Cancel subscription booking error: ${e.toString()}');
    }
  }
  
  // 13.5 Apply Promo Code to Subscription (already exists in subscription_booking_service)
  // This is kept for consistency but can use the one in SubscriptionBookingService
  
  // 13.6 Mark Subscription Attendance
  Future<Map<String, dynamic>?> markSubscriptionAttendance({
    required String subscriptionId,
    required String bookingId,
    required String attendanceStatus,
  }) async {
    try {
      final payload = {
        'subscriptionId': subscriptionId,
        'bookingId': bookingId,
        'attendanceStatus': attendanceStatus,
      };
      
      final response = await ApiService.post(
        '$baseUrl/booking/mark-Subscription-Attendance',
        payload,
        requireAuth: true,
      );
      
      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['error'] ?? 'Failed to mark subscription attendance');
      }
    } catch (e) {
      throw Exception('Mark subscription attendance error: ${e.toString()}');
    }
  }

  /// GET /booking/get-all-bookings (manual bookings)
  Future<List<dynamic>> getAllBookings() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-all-bookings',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['bookings'] is List) return data['bookings'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get bookings');
    } catch (e) {
      throw Exception('Get all bookings error: ${e.toString()}');
    }
  }

  /// GET /booking/get-booking/:bookingId (single manual booking)
  Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-booking/$bookingId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data'] as Map);
        return null;
      }
      throw Exception(response['error'] ?? 'Failed to get booking');
    } catch (e) {
      throw Exception('Get booking error: ${e.toString()}');
    }
  }

  /// DELETE /booking/delete-booking/:bookingId
  Future<Map<String, dynamic>?> deleteBooking(String bookingId) async {
    try {
      final response = await ApiService.delete(
        '$baseUrl/booking/delete-booking/$bookingId',
        requireAuth: true,
      );
      if (response['success'] == true) return response['data'];
      throw Exception(response['error'] ?? 'Failed to delete booking');
    } catch (e) {
      throw Exception('Delete booking error: ${e.toString()}');
    }
  }

  /// GET /booking/get-all-subscriptionBooking
  Future<List<dynamic>> getAllSubscriptionBookings() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-all-subscriptionBooking',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['bookings'] is List) return data['bookings'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get subscription bookings');
    } catch (e) {
      throw Exception('Get all subscription bookings error: ${e.toString()}');
    }
  }

  /// GET /booking/get-allCustomers-subscriptions/:subscriptionId
  Future<List<dynamic>> getCustomersBySubscription(String subscriptionId) async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-allCustomers-subscriptions/$subscriptionId',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['customers'] is List) return data['customers'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get customers');
    } catch (e) {
      throw Exception('Get customers by subscription error: ${e.toString()}');
    }
  }

  /// GET /booking/get-All-Subscription-Customers
  Future<List<dynamic>> getAllSubscriptionCustomers() async {
    try {
      final response = await ApiService.get(
        '$baseUrl/booking/get-All-Subscription-Customers',
        requireAuth: true,
      );
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
        if (data is Map && data['customers'] is List) return data['customers'] as List;
        return [];
      }
      throw Exception(response['error'] ?? 'Failed to get subscription customers');
    } catch (e) {
      throw Exception('Get all subscription customers error: ${e.toString()}');
    }
  }
}

