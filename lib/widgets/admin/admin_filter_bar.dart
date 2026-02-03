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
    return Card(
      elevation: AdminTheme.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
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
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
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
