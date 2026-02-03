import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminSectionCard extends StatelessWidget {
  final String? title;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdminSectionCard({
    super.key,
    this.title,
    this.action,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AdminTheme.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || action != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    if (action != null) action!,
                  ],
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}
