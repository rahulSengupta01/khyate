import 'package:flutter/material.dart';
import '../../../services/review_service.dart';
import '../../../widgets/admin/admin_theme.dart';
import '../../../widgets/admin/admin_section_card.dart';
import '../../../widgets/admin/admin_simple_table.dart';
import '../../../widgets/admin/admin_empty_state.dart';

class RatingsSection extends StatefulWidget {
  const RatingsSection({super.key});

  @override
  State<RatingsSection> createState() => _RatingsSectionState();
}

class _RatingsSectionState extends State<RatingsSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reviewService = ReviewService();
  List<Map<String, dynamic>> _trainerRatings = [];
  List<Map<String, dynamic>> _membershipRatings = [];
  bool _loadingTrainers = false;
  bool _loadingMemberships = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrainerRatings();
    _loadMembershipRatings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// GET /user/get-all-trainer-reviews — aggregate by trainer
  Future<void> _loadTrainerRatings() async {
    if (!mounted) return;
    setState(() => _loadingTrainers = true);
    try {
      final list = await _reviewService.getAllTrainerReviews();
      final aggregated = _aggregateTrainerReviews(list);
      if (!mounted) return;
      setState(() {
        _trainerRatings = aggregated;
        _loadingTrainers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _trainerRatings = [];
        _loadingTrainers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load trainer ratings: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _aggregateTrainerReviews(List<dynamic> list) {
    final byTrainer = <String, List<Map<String, dynamic>>>{};
    for (final e in list) {
      final m = e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{};
      final trainer = m['trainer'];
      final trainerId = (trainer is Map ? (trainer['_id'] ?? trainer['id']) : m['trainerId'] ?? m['trainer_id'])?.toString() ?? '';
      if (trainerId.isEmpty) continue;
      byTrainer.putIfAbsent(trainerId, () => []);
      byTrainer[trainerId]!.add(m);
    }
    return byTrainer.entries.map((e) {
      final reviews = e.value;
      final first = reviews.first;
      Object? trainer = first['trainer'];
      String name = '', email = '', spec = '';
      if (trainer is Map) {
        name = '${trainer['firstName'] ?? trainer['first_name'] ?? ''} ${trainer['lastName'] ?? trainer['last_name'] ?? ''}'.trim();
        if (name.isEmpty) name = (trainer['name'] ?? '').toString();
        email = (trainer['email'] ?? '').toString();
        spec = (trainer['specialization'] ?? '').toString();
      }
      final total = reviews.length;
      final avg = total > 0 ? reviews.fold<double>(0, (s, r) => s + ((r['rating'] ?? 0) as num).toDouble()) / total : 0.0;
      return {
        'trainerId': e.key,
        'name': name.isEmpty ? 'Trainer ${e.key}' : name,
        'email': email,
        'reviews': total,
        'rating': avg.round(),
        'averageRating': avg,
        'specialization': spec,
        'reviewsList': reviews,
      };
    }).toList();
  }

  /// GET /user/get-all-subscription-rating-review — aggregate by subscription
  Future<void> _loadMembershipRatings() async {
    if (!mounted) return;
    setState(() => _loadingMemberships = true);
    try {
      final list = await _reviewService.getAllSubscriptionRatingReview(requireAuth: true);
      final aggregated = _aggregateSubscriptionReviews(list);
      if (!mounted) return;
      setState(() {
        _membershipRatings = aggregated;
        _loadingMemberships = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _membershipRatings = [];
        _loadingMemberships = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load membership ratings: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _aggregateSubscriptionReviews(List<dynamic> list) {
    final bySub = <String, List<Map<String, dynamic>>>{};
    for (final e in list) {
      final m = e is Map ? Map<String, dynamic>.from(e as Map) : <String, dynamic>{};
      // Backend may return per-subscription summary: { subscription, reviews: [...], averageRating }
      final nestedReviews = m['reviews'] ?? m['reviewList'];
      if (nestedReviews is List && nestedReviews.isNotEmpty) {
        Object? subRef = m['subscription'] ?? m['subscriptionId'];
        String subId = subRef is String ? subRef : (subRef is Map ? (subRef['_id'] ?? subRef['id']) : null)?.toString() ?? (m['_id'] ?? m['id'] ?? 'sub').toString();
        for (final r in nestedReviews) {
          final rev = r is Map ? Map<String, dynamic>.from(r as Map) : <String, dynamic>{};
          rev['subscription'] = m['subscription'];
          rev['subscriptionId'] = subId;
          bySub.putIfAbsent(subId, () => []);
          bySub[subId]!.add(rev);
        }
        continue;
      }
      Object? subRef = m['subscription'] ?? m['subscriptionId'] ?? m['subscription_id'];
      String subId = '';
      if (subRef is String) subId = subRef;
      else if (subRef is Map) subId = (subRef['_id'] ?? subRef['id'] ?? '').toString();
      if (subId.isEmpty) subId = (m['packageId'] ?? m['package_id'] ?? m['_id'] ?? m['id'] ?? '').toString();
      if (subId.isEmpty) subId = 'other';
      bySub.putIfAbsent(subId, () => []);
      bySub[subId]!.add(m);
    }
    return bySub.entries.map((e) {
      final reviews = e.value;
      final first = reviews.first;
      Object? sub = first['subscription'];
      String name = '';
      if (sub is Map) name = (sub['name'] ?? sub['title'] ?? sub['subscriptionName'] ?? sub['subscription_name'] ?? '').toString();
      if (name.isEmpty) name = e.key == 'other' ? 'Other reviews' : 'Subscription ${e.key}';
      final total = reviews.length;
      num ratingSum = 0;
      for (final r in reviews) {
        final v = r['rating'] ?? r['ratingValue'];
        if (v is num) ratingSum += v;
        else if (v != null) ratingSum += (double.tryParse(v.toString()) ?? 0);
      }
      final avg = total > 0 ? ratingSum / total : 0.0;
      return {
        'subscriptionId': e.key,
        'name': name,
        'reviews': total,
        'rating': avg.round().clamp(0, 5),
        'averageRating': avg,
        'reviewsList': reviews,
      };
    }).toList();
  }

  /// GET /user/get-trainer-review/:trainerId — view details; admin reply/hide
  void _showTrainerReviewDetails(Map<String, dynamic> row) {
    final trainerId = (row['trainerId'] ?? '').toString();
    final reviews = (row['reviewsList'] as List<dynamic>?) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => _ReviewDetailsSheet(
          title: 'Reviews: ${row['name']}',
          reviews: reviews,
          onReply: (reviewId, reply) async {
            await _reviewService.replyToTrainerReview(reviewId: reviewId, reply: reply);
            if (context.mounted) Navigator.pop(ctx);
            _loadTrainerRatings();
          },
          onToggleVisibility: (reviewId, isHidden) async {
            await _reviewService.toggleTrainerReviewVisibility(reviewId: reviewId, isHidden: isHidden);
            if (context.mounted) Navigator.pop(ctx);
            _loadTrainerRatings();
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showMembershipReviewDetails(Map<String, dynamic> row) {
    final reviews = (row['reviewsList'] as List<dynamic>?) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => _ReviewDetailsSheet(
          title: 'Reviews: ${row['name']}',
          reviews: reviews,
          onReply: (reviewId, reply) async {
            await _reviewService.replyToSubscriptionReview(reviewId: reviewId, reply: reply);
            if (context.mounted) Navigator.pop(ctx);
            _loadMembershipRatings();
          },
          onToggleVisibility: (reviewId, isHidden) async {
            await _reviewService.toggleSubscriptionReviewVisibility(reviewId: reviewId, isHidden: isHidden);
            if (context.mounted) Navigator.pop(ctx);
            _loadMembershipRatings();
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AdminTheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Trainers'),
            Tab(text: 'Memberships'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRatingsTable(
                'Trainer Ratings',
                _trainerRatings,
                _loadingTrainers,
                ['S.No', 'Photo', 'Name', 'Email', 'Total Reviews', 'Average Rating', 'Specialization', 'Action'],
                (r, i) => [
                  Text('${i + 1}'),
                  const CircleAvatar(child: Icon(Icons.person)),
                  Text((r['name'] ?? '').toString()),
                  Text((r['email'] ?? '').toString()),
                  Text((r['reviews'] ?? '0').toString()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (j) => Icon(Icons.star, size: 16, color: j < ((r['rating'] ?? 0) as num).toInt() ? AdminTheme.warning : Theme.of(context).colorScheme.outline)),
                  ),
                  Text((r['specialization'] ?? '').toString()),
                  TextButton(
                    onPressed: () => _showTrainerReviewDetails(r),
                    child: const Text('View details'),
                  ),
                ],
              ),
              _buildRatingsTable(
                'Membership Ratings',
                _membershipRatings,
                _loadingMemberships,
                ['S.No', 'Photo', 'Name', 'Total Reviews', 'Average Rating', 'Action'],
                (r, i) => [
                  Text('${i + 1}'),
                  const CircleAvatar(child: Icon(Icons.card_membership)),
                  Text((r['name'] ?? '').toString()),
                  Text((r['reviews'] ?? '0').toString()),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (j) => Icon(Icons.star, size: 16, color: j < ((r['rating'] ?? 0) as num).toInt() ? AdminTheme.warning : Theme.of(context).colorScheme.outline)),
                  ),
                  TextButton(
                    onPressed: () => _showMembershipReviewDetails(r),
                    child: const Text('View details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingsTable(
    String title,
    List<Map<String, dynamic>> data,
    bool loading,
    List<String> columns,
    List<Widget> Function(Map<String, dynamic> r, int i) rowBuilder,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AdminSectionCard(
        title: title,
        child: data.isEmpty && !loading
            ? AdminEmptyState(
                icon: Icons.star_outline,
                message: 'No ratings yet. Connect reviews API to load data.',
              )
            : AdminSimpleTable(
                columnLabels: columns,
                rows: data.asMap().entries.map((e) => rowBuilder(e.value, e.key)).toList(),
                isLoading: loading,
              ),
          ),
    );
  }
}

/// Bottom sheet listing reviews with Reply and Hide for each (admin).
class _ReviewDetailsSheet extends StatefulWidget {
  final String title;
  final List<dynamic> reviews;
  final Future<void> Function(String reviewId, String reply) onReply;
  final Future<void> Function(String reviewId, bool isHidden) onToggleVisibility;
  final ScrollController scrollController;

  const _ReviewDetailsSheet({
    required this.title,
    required this.reviews,
    required this.onReply,
    required this.onToggleVisibility,
    required this.scrollController,
  });

  @override
  State<_ReviewDetailsSheet> createState() => _ReviewDetailsSheetState();
}

class _ReviewDetailsSheetState extends State<_ReviewDetailsSheet> {
  final _replyControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _replyControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(widget.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: widget.reviews.length,
            itemBuilder: (_, i) {
              final r = widget.reviews[i] is Map ? Map<String, dynamic>.from(widget.reviews[i] as Map) : <String, dynamic>{};
              final reviewId = (r['_id'] ?? r['id'] ?? '').toString();
              final rating = (r['rating'] ?? 0) as num;
              final review = (r['review'] ?? r['comment'] ?? '').toString();
              final isHidden = r['isHidden'] == true || r['is_hidden'] == true;
              final adminReply = (r['adminReply'] ?? r['admin_reply'] ?? r['reply'] ?? '').toString();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (j) => Icon(Icons.star, size: 18, color: j < rating.toInt() ? AdminTheme.warning : Theme.of(context).colorScheme.outline)),
                          const SizedBox(width: 8),
                          if (isHidden) Chip(label: Text('Hidden', style: TextStyle(fontSize: 12, color: AdminTheme.error))),
                        ],
                      ),
                      if (review.isNotEmpty) const SizedBox(height: 8),
                      if (review.isNotEmpty) Text(review, style: const TextStyle(fontSize: 14)),
                      if (adminReply.isNotEmpty) ...[const SizedBox(height: 8), Text('Reply: $adminReply', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant))],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.reply, size: 18),
                            label: const Text('Reply'),
                            onPressed: () => _showReplyDialog(context, reviewId),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: Icon(isHidden ? Icons.visibility : Icons.visibility_off, size: 18),
                            label: Text(isHidden ? 'Show' : 'Hide'),
                            onPressed: () => widget.onToggleVisibility(reviewId, !isHidden),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showReplyDialog(BuildContext context, String reviewId) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin reply'),
        content: TextField(
          controller: c,
          decoration: AdminTheme.inputDecoration(context, hintText: 'Enter reply'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: AdminTheme.primaryButtonStyle,
            onPressed: () async {
              final reply = c.text.trim();
              if (reply.isEmpty) return;
              Navigator.pop(ctx);
              await widget.onReply(reviewId, reply);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
