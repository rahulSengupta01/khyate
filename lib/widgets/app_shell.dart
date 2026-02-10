import 'package:Outbox/screens/admin_dashboard.dart';
import 'package:Outbox/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
// import 'package:khyate_b2b/screens/admin_dashboard.dart';
// import 'package:khyate_b2b/screens/profile_screen.dart';
// import 'dashboard_screen.dart'; // ← Create this screen

typedef AppShellPageBuilder = Widget Function(
  BuildContext context,
  bool isDarkMode,
);

class AppShellPage {
  const AppShellPage({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final AppShellPageBuilder builder;
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.pages,
    required this.onLogout,
    this.initialIndex = 0,
    this.landingBuilder,
  }) : assert(pages.length >= 1, 'Provide at least one page to AppShell');

  final List<AppShellPage> pages;
  final Future<void> Function() onLogout;
  final int initialIndex;
  final AppShellPageBuilder? landingBuilder;

  @override
  State<AppShell> createState() => _AppShellState();

  // Static method to navigate to tab from child widgets
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    state?.navigateToTab(index);
  }

  // Accessors for shared actions/state from descendants
  static _AppShellState? _maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<_AppShellState>();

  static bool isAdmin(BuildContext context) =>
      _maybeOf(context)?._isAdmin ?? false;

  static bool isDarkMode(BuildContext context) =>
      context.watch<ThemeProvider>().isDarkMode;

  static void showLogoutDialog(BuildContext context) =>
      _maybeOf(context)?._showLogoutConfirmation(context);

  static void toggleTheme(BuildContext context) =>
      context.read<ThemeProvider>().toggleTheme();

  static void openProfileOrAdmin(BuildContext context) =>
      _maybeOf(context)?._onProfilePressed();

  static void showAdminOptions(BuildContext context) =>
      _maybeOf(context)?._showAdminOptions();
}

class _AppShellState extends State<AppShell> {
  static const Color _barColor = Color(0xFF111827);

  late int _selectedIndex;
  late bool _hasNavSelection;

  // 🔥 Admin flag
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.pages.length - 1);
    _hasNavSelection = widget.landingBuilder == null;

    _checkAdmin(); // 🔥 fetch admin status
  }

  // ⭐ Fetch isAdmin from stored role
  Future<void> _checkAdmin() async {
    final isAdminUser = await ApiService.isAdmin();
    if (mounted) {
      setState(() => _isAdmin = isAdminUser);
    }
  }

  // ⭐ Logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final Color dialogBg = theme.colorScheme.surface;
    final Color titleColor = theme.colorScheme.onSurface;
    final Color textColor = theme.colorScheme.onSurfaceVariant;
    final Color borderColor = theme.brightness == Brightness.dark ? const Color(0xFF3A4555) : const Color(0xFFE2E8F0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'You will need to sign in again to access your account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await widget.onLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ⭐ Admin popup dialog
  void _showAdminOptions() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Select an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  Navigator.pop(ctx);
                  final isDark = context.read<ThemeProvider>().isDarkMode;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(isDarkMode: isDark),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminDashboard(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onProfilePressed() async {
    // Re-check admin status in case it wasn't set yet
    final isAdminUser = await ApiService.isAdmin();
    if (mounted) {
      setState(() => _isAdmin = isAdminUser);
    }
    
    if (_isAdmin) {
      _showAdminOptions();
    } else {
      final isDark = context.read<ThemeProvider>().isDarkMode;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(isDarkMode: isDark),
        ),
      );
    }
  }

  void _onNavTapped(int index) {
    if (_hasNavSelection && index == _selectedIndex) return;
    setState(() {
      _hasNavSelection = true;
      _selectedIndex = index;
    });
  }

  void navigateToTab(int index) {
    _onNavTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final Color scaffoldBackground = Theme.of(context).scaffoldBackgroundColor;
    final bool showSelection = _hasNavSelection;
    final int cartCount = context.watch<CartProvider>().items.length;

    final Widget displayedPage = showSelection
        ? widget.pages[_selectedIndex].builder(context, isDarkMode)
        : widget.landingBuilder!(context, isDarkMode);

    final Widget currentPage = KeyedSubtree(
      key: ValueKey(
        '${showSelection ? 'page_$_selectedIndex' : 'landing'}_${isDarkMode ? 'dark' : 'light'}',
      ),
      child: displayedPage,
    );

    final bool canPop = Navigator.of(context).canPop();
    final bool showBackToLanding = showSelection && !canPop;
    final String? appBarTitle =
        showSelection ? widget.pages[_selectedIndex].label : null;

    return Scaffold(
      key: ValueKey(
        '${showSelection ? 'page_$_selectedIndex' : 'landing'}_${isDarkMode ? 'dark' : 'light'}',
      ),
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: _barColor,
        elevation: 0,
        leadingWidth: (canPop || showBackToLanding) ? 64 : 200,
        leading: (canPop || showBackToLanding)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
                onPressed: () {
                  if (canPop) {
                    Navigator.of(context).maybePop();
                  } else if (showBackToLanding) {
                    setState(() {
                      _hasNavSelection = false;
                    });
                  }
                },
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SizedBox(
                  height: 35,
                  width: 140,
                  child: Image.asset(
                    'assets/company.png',
                    fit: BoxFit.contain,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return frame != null ? child : const SizedBox();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading company.png: $error');
                      return const Icon(Icons.image,
                          color: Colors.white, size: 35);
                    },
                  ),
                ),
              ),
        title: appBarTitle != null
            ? Text(
                appBarTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              )
            : null,
        centerTitle: false,
        actions: [
          // 🔥 Profile button with admin logic
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
            onPressed: _onProfilePressed,
          ),

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _showLogoutConfirmation(context),
          ),

          IconButton(
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
              color: Colors.white,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: currentPage,
      ),
      bottomNavigationBar: Container(
        color: _barColor,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: showSelection ? Colors.amberAccent : Colors.white70,
          unselectedItemColor: Colors.white70,
          selectedIconTheme: showSelection
              ? const IconThemeData(color: Colors.amberAccent)
              : const IconThemeData(color: Colors.white70),
          selectedLabelStyle:
              showSelection ? null : const TextStyle(color: Colors.white70),
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onNavTapped,
          items: widget.pages.map((page) {
          final bool isCart = page.label.toLowerCase() == 'cart';
          final Widget icon = isCart && cartCount > 0
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(page.icon),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Icon(page.icon);

          return BottomNavigationBarItem(
            icon: icon,
            label: page.label,
          );
        }).toList(),
        ),
      ),
    );
  }
}
