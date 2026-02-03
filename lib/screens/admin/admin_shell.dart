import 'package:flutter/material.dart';
import '../../widgets/admin/admin_theme.dart';

enum AdminSection {
  customers,
  trainers,
  memberships,
  promoCodes,
  payments,
  ratings,
  masters,
}

class AdminShell extends StatefulWidget {
  final Widget child;
  final AdminSection currentSection;
  final String sectionTitle;
  final ValueChanged<AdminSection> onSectionChanged;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentSection,
    required this.sectionTitle,
    required this.onSectionChanged,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _sidebarCollapsed = false;
  bool _isDrawerOpen = false;

  static const _sections = [
    (AdminSection.customers, Icons.people_outline, 'Customers'),
    (AdminSection.trainers, Icons.person_outline, 'Trainers'),
    (AdminSection.memberships, Icons.card_membership, 'Memberships'),
    (AdminSection.promoCodes, Icons.local_offer_outlined, 'Promo Codes'),
    (AdminSection.payments, Icons.payment, 'Payments'),
    (AdminSection.ratings, Icons.star_outline, 'Ratings'),
    (AdminSection.masters, Icons.settings, 'Masters'),
  ];

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Row(
            children: [
              if (!isNarrow) _buildSidebar(context),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, isNarrow),
                    Expanded(
                      child: Material(
                        color: AdminTheme.surface,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      drawer: isNarrow ? _buildDrawer(context) : null,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _sidebarCollapsed ? AdminTheme.sidebarWidthCollapsed : AdminTheme.sidebarWidth,
      decoration: BoxDecoration(
        color: AdminTheme.cardBgDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: _sidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (!_sidebarCollapsed) const SizedBox(width: 20),
              Icon(Icons.dashboard, color: AdminTheme.primary, size: 28),
              if (!_sidebarCollapsed) ...[
                const SizedBox(width: 12),
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          ..._sections.map((e) => _navItem(context, e.$1, e.$2, e.$3)),
          const Spacer(),
          IconButton(
            icon: Icon(
              _sidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, AdminSection section, IconData icon, String label) {
    final isSelected = widget.currentSection == section;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AdminTheme.primary.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(AdminTheme.radiusButton),
        child: InkWell(
          onTap: () => widget.onSectionChanged(section),
          borderRadius: BorderRadius.circular(AdminTheme.radiusButton),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarCollapsed ? 12 : 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AdminTheme.primary : Colors.white70,
                ),
                if (!_sidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AdminTheme.primary : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Drawer? _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AdminTheme.cardBgDark,
      child: ListView(
        padding: const EdgeInsets.only(top: 24),
        children: [
          const ListTile(
            leading: Icon(Icons.dashboard, color: AdminTheme.primary, size: 28),
            title: Text('Admin', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.white24),
          ..._sections.map((e) => ListTile(
            leading: Icon(e.$2, color: widget.currentSection == e.$1 ? AdminTheme.primary : Colors.white70),
            title: Text(
              e.$3,
              style: TextStyle(
                color: widget.currentSection == e.$1 ? AdminTheme.primary : Colors.white70,
                fontWeight: widget.currentSection == e.$1 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onSectionChanged(e.$1);
            },
          )),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AdminTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isNarrow)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (isNarrow) const SizedBox(width: 8),
          Text(
            widget.sectionTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AdminTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
