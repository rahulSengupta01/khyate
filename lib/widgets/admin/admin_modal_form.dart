import 'package:flutter/material.dart';
import 'admin_theme.dart';

class AdminModalForm extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onReset;
  final VoidCallback? onSave;
  final String saveLabel;
  final bool saveLoading;

  const AdminModalForm({
    super.key,
    required this.title,
    required this.children,
    this.onReset,
    this.onSave,
    this.saveLabel = 'Save',
    this.saveLoading = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    VoidCallback? onReset,
    VoidCallback? onSave,
    String saveLabel = 'Save',
    bool saveLoading = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminModalForm(
        title: title,
        children: children,
        onReset: onReset,
        onSave: onSave,
        saveLabel: saveLabel,
        saveLoading: saveLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? AdminTheme.cardBgDark : AdminTheme.cardBgTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isSmall ? double.infinity : 560,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReset != null)
                    TextButton(
                      onPressed: onReset,
                      child: const Text('Reset'),
                    ),
                  const SizedBox(width: 8),
                  if (onSave != null)
                    FilledButton(
                      onPressed: saveLoading ? null : onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AdminTheme.primary,
                        foregroundColor: AdminTheme.textOnPrimary,
                      ),
                      child: saveLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(saveLabel),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
