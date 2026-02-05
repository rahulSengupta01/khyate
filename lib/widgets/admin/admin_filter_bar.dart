import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminFilterBar extends StatelessWidget {
  final List<Widget> filters;
  final Widget? searchField;
  final VoidCallback? onClearFilters;

  const AdminFilterBar({
    super.key,
    required this.filters,
    this.searchField,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AdminTheme.filterBarBgDark : AdminTheme.filterBarBg;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
        border: Border.all(
          color: isDark ? AdminTheme.borderDark : AdminTheme.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                ...filters,
                if (onClearFilters != null)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear Filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (searchField != null) ...[
              const SizedBox(height: 12),
              searchField!,
            ],
          ],
        ),
      ),
    );
  }
}
