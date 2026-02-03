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
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    return Card(
      elevation: AdminTheme.elevationCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(surfaceColor),
              columns: columnLabels
                  .map((c) => DataColumn(
                        label: Text(
                          c,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ))
                  .toList(),
              rows: isLoading
                  ? List.generate(
                      rowsPerPage,
                      (_) => DataRow(
                        cells: columnLabels
                            .map((_) => const DataCell(SizedBox(height: 24, width: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))))
                            .toList(),
                      ),
                    )
                  : rows
                      .map(
                        (cells) => DataRow(
                          cells: cells.map((c) => DataCell(c)).toList(),
                        ),
                      )
                      .toList(),
            ),
          ),
          if (onPageChanged != null && totalPages > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: surfaceColor),
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
