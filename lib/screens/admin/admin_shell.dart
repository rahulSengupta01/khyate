import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/admin/admin_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../providers/cart_provider.dart';
import '../login_screen.dart';

enum AdminSection {
  customers,
  trainers,
  memberships,
  promoCodes,
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

/// Dark top bar (same as AppShell) - matches ThemeProvider.barColor.
const Color _adminBarColorDark = Color(0xFF111827);
/// Light top bar / sidebar.
const Color _adminBarColorLight = Color(0xFFF8FAFC);
/// Sidebar/drawer: cyan background (AdminTheme.primary), white text.
const Color _sidebarTextWhite = Color(0xFFFFFFFF);
const Color _sidebarTextMuted = Color(0xFFE0E0E0);

class _AdminShellState extends State<AdminShell> {
  bool _sidebarCollapsed = false;
  bool _isDrawerOpen = false;

  static const _sections = [
    (AdminSection.customers, Icons.people_outline, 'Customers'),
    (AdminSection.trainers, Icons.person_outline, 'Trainers'),
    (AdminSection.memberships, Icons.card_membership, 'Memberships'),
    (AdminSection.promoCodes, Icons.local_offer_outlined, 'Promo Codes'),
    (AdminSection.ratings, Icons.star_outline, 'Ratings'),
    (AdminSection.masters, Icons.settings, 'Masters'),
  ];

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final contentBg = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Builder(
        builder: (context) {
          return Row(
            children: [
              if (!isNarrow) _buildSidebar(context, isDarkMode),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: contentBg,
                    gradient: isDarkMode
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFF8FAFC),
                              const Color(0xFFF1F5F9),
                              AdminTheme.primary.withOpacity(0.03),
                            ],
                          ),
                  ),
                  child: SafeArea(
                    top: true,
                    bottom: false,
                    left: false,
                    right: false,
                    child: Column(
                      children: [
                        _buildTopBar(context, isNarrow, isDarkMode),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: widget.child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      drawer: isNarrow ? _buildDrawer(context, isDarkMode) : null,
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _sidebarCollapsed ? AdminTheme.sidebarWidthCollapsed : AdminTheme.sidebarWidth,
      decoration: BoxDecoration(
        color: AdminTheme.primary,
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
              const Icon(Icons.dashboard, color: _sidebarTextWhite, size: 28),
              if (!_sidebarCollapsed) ...[
                const SizedBox(width: 12),
                const Text(
                  'Admin',
                  style: TextStyle(
                    color: _sidebarTextWhite,
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
              color: _sidebarTextMuted,
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
        color: isSelected ? _sidebarTextWhite.withOpacity(0.2) : Colors.transparent,
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
                  color: isSelected ? _sidebarTextWhite : _sidebarTextMuted,
                ),
                if (!_sidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? _sidebarTextWhite : _sidebarTextMuted,
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

  Drawer? _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      backgroundColor: AdminTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(top: 24),
        children: [
          const ListTile(
            leading: Icon(Icons.dashboard, color: _sidebarTextWhite, size: 28),
            title: Text('Admin', style: TextStyle(color: _sidebarTextWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: _sidebarTextMuted),
          ..._sections.map((e) => ListTile(
            leading: Icon(e.$2, color: widget.currentSection == e.$1 ? _sidebarTextWhite : _sidebarTextMuted),
            title: Text(
              e.$3,
              style: TextStyle(
                color: widget.currentSection == e.$1 ? _sidebarTextWhite : _sidebarTextMuted,
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

  Widget _buildTopBar(BuildContext context, bool isNarrow, bool isDarkMode) {
    final barColor = isDarkMode ? _adminBarColorDark : _adminBarColorLight;
    final barDecoration = BoxDecoration(
      color: barColor,
      border: Border(
        bottom: BorderSide(
          color: isDarkMode ? AdminTheme.borderDark : AdminTheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
    final barIconColor = isDarkMode ? Colors.white : AdminTheme.textPrimary;
    final barTextColor = isDarkMode ? Colors.white : AdminTheme.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First bar: Dashboard (page name) + back + profile + theme toggle + logout
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: barDecoration,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: barIconColor),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: barTextColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.person_outline, color: barIconColor),
                onPressed: () {},
                tooltip: 'Profile',
              ),
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                  color: barIconColor,
                ),
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.logout, color: barIconColor),
                tooltip: 'Logout',
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ],
          ),
        ),
        // Second bar: same colour; menu (if narrow) + section title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: barDecoration,
          child: Row(
            children: [
              if (isNarrow) ...[
                IconButton(
                  icon: Icon(Icons.menu, color: barIconColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.sectionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: barTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (!context.mounted) return;
              context.read<CartProvider>().clearCart();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
