import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const AdminSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AdminTheme.fieldBgDark : null;
    final borderColor = isDark ? AdminTheme.fieldBorderDark : null;
    final titleColor = isDark ? AdminTheme.fieldTextMutedDark : Theme.of(context).colorScheme.onSurfaceVariant;
    final valueColor = isDark ? AdminTheme.fieldTextDark : Theme.of(context).colorScheme.onSurface;
    return Card(
      elevation: AdminTheme.elevationCard,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
        side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.withOpacity(isDark ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(AdminTheme.radiusButton),
              ),
              child: Icon(icon, color: c, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminTheme.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSummaryCards extends StatelessWidget {
  final List<AdminSummaryCard> children;

  const AdminSummaryCards({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}
