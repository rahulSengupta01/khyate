import 'package:flutter/material.dart';
import 'admin_theme.dart';

/// Table that takes a list of row widgets (each row is a list of cells).
class AdminSimpleTable extends StatelessWidget {
  final List<String> columnLabels;
  final List<List<Widget>> rows;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int>? onPageChanged;
  final int rowsPerPage;

  const AdminSimpleTable({
    super.key,
    required this.columnLabels,
    required this.rows,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.onPageChanged,
    this.rowsPerPage = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerBg = isDark ? AdminTheme.tableHeaderBgDark : AdminTheme.tableHeaderBg;
    final headerText = isDark ? AdminTheme.textOnPrimary : AdminTheme.primaryDark;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AdminTheme.cardBgDark : Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
        border: Border.all(color: isDark ? AdminTheme.borderDark : AdminTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
              headingRowHeight: 52,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              horizontalMargin: 20,
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(headerBg),
              dividerThickness: 1,
              columns: columnLabels
                  .map((c) => DataColumn(
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: headerText,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              rows: isLoading
                  ? List.generate(
                      rowsPerPage,
                      (index) => DataRow(
                        color: WidgetStateProperty.all(
                          index.isEven ? (isDark ? AdminTheme.cardBgDark : AdminTheme.tableRowAlt) : null,
                        ),
                        cells: columnLabels
                            .map((_) => const DataCell(SizedBox(height: 24, width: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))))
                            .toList(),
                      ),
                    )
                  : rows
                      .asMap()
                      .entries
                      .map(
                        (entry) => DataRow(
                          color: WidgetStateProperty.all(
                            entry.key.isEven ? (isDark ? AdminTheme.cardBgDark : AdminTheme.tableRowAlt) : null,
                          ),
                          cells: entry.value.map((c) => DataCell(c)).toList(),
                        ),
                      )
                      .toList(),
                  ),
                ),
              );
            },
          ),
          if (onPageChanged != null && totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AdminTheme.surfaceDark : AdminTheme.surface,
                border: Border(top: BorderSide(color: isDark ? AdminTheme.borderDark : AdminTheme.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${((currentPage - 1) * rowsPerPage) + 1}–${(currentPage * rowsPerPage).clamp(0, totalItems)} of $totalItems',
                    style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1 ? () => onPageChanged!(currentPage - 1) : null,
                      ),
                      Text('$currentPage / $totalPages', style: TextStyle(fontSize: 13, color: onSurface)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages ? () => onPageChanged!(currentPage + 1) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
