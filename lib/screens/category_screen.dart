import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/membership_card_model.dart';
import '../utils/card_display_utils.dart';
import '../services/subscription_service.dart';
import '../services/subscription_booking_service.dart';
import '../widgets/membership_card.dart';
import '../widgets/membership_modal.dart';

/// Generic category screen showing subscriptions for a given category (from API).
class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final bool isDarkMode;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.isDarkMode,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _subscriptionService = SubscriptionService();
  final _bookingService = SubscriptionBookingService();

  Stream<List<MembershipCardData>> _getSubscriptionsStream() async* {
    try {
      // Use category-specific endpoint so we only get this category's content, not fitness/others
      final result = await _subscriptionService.getSubscriptionsByCategoryId(
        categoryId: widget.categoryId,
        page: 1,
        limit: 100,
      );
      var raw = result;
      var list = raw is List ? raw : (raw?['subscriptions'] ?? raw?['data'] ?? []);
      if (list is! List) list = [];
      // Client-side filter: only show subscriptions that belong to this category
      final myId = widget.categoryId;
      final subscriptions = list.where((sub) {
        final cat = sub['categoryId'];
        if (cat == null) return false;
        final catId = cat is Map ? (cat['_id'] ?? cat['id'])?.toString() : cat.toString();
        return catId == myId;
      }).toList();

      List<String> purchasedIds = [];
      try {
        final bookings = await _bookingService.getBookingHistory();
        purchasedIds = bookings.map((b) {
          final id = b['subscriptionId'] ?? b['subscription'];
          if (id is Map) return id['_id']?.toString() ?? '';
          return id?.toString() ?? '';
        }).where((id) => id.isNotEmpty).toList();
      } catch (_) {}

      final cards = subscriptions.map<MembershipCardData>((sub) {
        final id = sub['_id']?.toString() ?? sub['id']?.toString() ?? '';
        final trainer = sub['trainer'];
        final trainerName = trainer is Map
            ? '${trainer['first_name'] ?? ''} ${trainer['last_name'] ?? ''}'.trim()
            : trainer?.toString() ?? 'Unknown';
        final address = sub['Address'] is Map ? sub['Address'] : {};
        final location = formatCardLocation(address);
        final dates = sub['date'];
        String dateStr = '';
        if (dates is List && dates.isNotEmpty) dateStr = dates.first?.toString() ?? '';
        if (dates is String) dateStr = dates;
        final category = sub['categoryId'];
        String catName = widget.categoryName;
        if (category is Map) {
          catName = (category['cName'] ?? category['name'] ?? widget.categoryName).toString();
        }
        return MembershipCardData(
          id: id,
          title: sub['name'] ?? 'Class',
          mentor: trainerName,
          date: dateStr,
          location: location,
          imageUrl: sub['media'] ?? sub['imageUrl'] ?? '',
          price: sub['price']?.toString() ?? '0',
          description: sub['description'] ?? '',
          category: catName,
          time: '${sub['startTime'] ?? ''} - ${sub['endTime'] ?? ''}',
          reviews: '0',
          isPurchased: purchasedIds.contains(id),
        );
      }).toList();

      yield cards;
    } catch (e) {
      yield [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.isDarkMode ? const Color(0xFF353535) : const Color(0xFFFCEEE5);
    final Color headlineColor = widget.isDarkMode ? const Color(0xFF20C8B1) : const Color(0xFF353535);
    final Color subTextColor = const Color(0xFF99928D);
    final Color accentColor = const Color(0xFF20C8B1);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              widget.categoryName,
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: headlineColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore ${widget.categoryName} classes and memberships',
              style: GoogleFonts.inter(fontSize: 16, color: subTextColor),
            ),
            const SizedBox(height: 28),
            StreamBuilder<List<MembershipCardData>>(
              stream: _getSubscriptionsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 64, color: accentColor.withOpacity(0.7)),
                        const SizedBox(height: 24),
                        Text(
                          'Coming soon',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: headlineColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Classes and memberships for ${widget.categoryName} will appear here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: subTextColor, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: headlineColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final card = list[i];
                        return MembershipCard(
                          data: card,
                          onTap: () => MembershipModal.show(context, card, widget.isDarkMode),
                          cardBackgroundColor: widget.isDarkMode ? const Color(0xFF1E293B) : null,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
