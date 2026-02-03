import 'package:flutter/material.dart';
import '../package_manager.dart';
import '../subscription_manager.dart';
import '../../../widgets/admin/admin_theme.dart';

/// Memberships section: tabbed layout (Programs | Membership).
/// Programs use subscription data; Membership uses packages.
class MembershipsSection extends StatefulWidget {
  const MembershipsSection({super.key});

  @override
  State<MembershipsSection> createState() => _MembershipsSectionState();
}

class _MembershipsSectionState extends State<MembershipsSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AdminTheme.primary,
          unselectedLabelColor: AdminTheme.textSecondary,
          tabs: const [
            Tab(text: 'Programs'),
            Tab(text: 'Membership'),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _wrapPadding(const SubscriptionManager(title: 'Programs')),
              _wrapPadding(PackageManager()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wrapPadding(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: child,
    );
  }
}
