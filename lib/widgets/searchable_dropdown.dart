import 'package:flutter/material.dart';

/// A searchable dropdown widget for selecting items from a large list
class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String? value;
  final List<T> items;
  final String Function(T) displayText;
  final String Function(T) getValue;
  final void Function(String?) onChanged;
  final String? hintText;
  final bool isRequired;
  final IconData? prefixIcon;
  /// When set, the trigger box uses this decoration (e.g. admin dark blue).
  final BoxDecoration? decoration;
  /// When set, label and value use these styles (e.g. admin field text).
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.displayText,
    required this.getValue,
    required this.onChanged,
    this.hintText,
    this.isRequired = false,
    this.prefixIcon,
    this.decoration,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = List<T>.from(widget.items);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = List<T>.from(widget.items);
      _searchController.clear();
    }
  }

  void _filterItems(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List<T>.from(widget.items);
      } else {
        _filteredItems = widget.items.where((item) {
          try {
            final text = widget.displayText(item).toLowerCase();
            return text.contains(query.toLowerCase());
          } catch (e) {
            return false;
          }
        }).toList();
      }
    });
  }

  void _showSearchDialog() {
    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${widget.label.toLowerCase()} available')),
      );
      return;
    }
    
    _searchController.clear();
    _filteredItems = List<T>.from(widget.items);
    
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) {
          return Dialog(
            backgroundColor: scheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  // Search field — filter and rebuild dialog so list updates
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search ${widget.label.toLowerCase()}...',
                        prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                      ),
                      onChanged: (value) {
                        _filterItems(value);
                        setDialogState(() {});
                      },
                      autofocus: true,
                    ),
                  ),
                  // List of items (reads current _filteredItems when dialog rebuilds)
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('No items found', style: TextStyle(color: scheme.onSurfaceVariant)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredItems.length,
                            itemBuilder: (listContext, index) {
                              if (index >= _filteredItems.length) {
                                return const SizedBox.shrink();
                              }
                              try {
                                final item = _filteredItems[index];
                                if (item == null) {
                                  return const SizedBox.shrink();
                                }
                                final itemValue = widget.getValue(item);
                                final isSelected = widget.value != null && widget.value == itemValue;

                                return ListTile(
                                  title: Text(
                                    widget.displayText(item),
                                    style: TextStyle(fontSize: 16, color: scheme.onSurface),
                                  ),
                                  selected: isSelected,
                                  selectedTileColor: scheme.primaryContainer,
                                  leading: isSelected
                                      ? Icon(Icons.check_circle, color: scheme.primary, size: 24)
                                      : Icon(Icons.radio_button_unchecked, color: scheme.onSurfaceVariant, size: 24),
                                  onTap: () {
                                    final value = widget.getValue(item);
                                    if (value.isNotEmpty) {
                                      widget.onChanged(value);
                                      Navigator.pop(dialogContext);
                                    }
                                  },
                                );
                              } catch (e) {
                                print('Error in searchable dropdown item: $e');
                                return ListTile(
                                  title: Text('Error loading item', style: TextStyle(color: scheme.error)),
                                  enabled: false,
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    T? selectedItem;
    try {
      if (widget.items.isNotEmpty && widget.value != null) {
        selectedItem = widget.items.firstWhere(
          (item) => widget.getValue(item) == widget.value,
          orElse: () => widget.items.first,
        );
        // Verify it's actually the selected one
        if (selectedItem != null && widget.getValue(selectedItem) != widget.value) {
          selectedItem = null;
        }
      }
    } catch (e) {
      selectedItem = null;
    }
    
    final displayValue = widget.value != null && selectedItem != null
        ? widget.displayText(selectedItem!)
        : widget.hintText ?? 'Select ${widget.label}';

    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surfaceContainerHighest;
    final borderColor = scheme.outline;
    final labelColor = scheme.onSurfaceVariant;
    final valueColor = scheme.onSurface;

    final boxDecoration = widget.decoration ??
        BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
          color: surface,
        );
    final effectiveLabelStyle = widget.labelStyle ??
        TextStyle(
          fontSize: 12,
          color: labelColor,
          fontWeight: FontWeight.w500,
        );
    final effectiveValueStyle = widget.valueStyle ??
        TextStyle(
          fontSize: 16,
          color: widget.value != null ? valueColor : labelColor,
        );
    final iconColor = widget.labelStyle?.color ?? labelColor;

    return InkWell(
      onTap: _showSearchDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: boxDecoration,
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(widget.prefixIcon, color: iconColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label + (widget.isRequired ? ' *' : ''),
                    style: effectiveLabelStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayValue,
                    style: effectiveValueStyle,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: iconColor),
          ],
        ),
      ),
    );
  }
}

