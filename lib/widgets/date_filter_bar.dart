import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable calendar-based date filter for Fitness and Wellness pages.
/// Shows "Any date" or the selected date; tap opens date picker.
class DateFilterBar extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final Color accentColor;
  final bool isDarkMode;

  const DateFilterBar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    required this.accentColor,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateSelected(DateTime(picked.year, picked.month, picked.day));
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, color: accentColor, size: 20),
          const SizedBox(width: 4),
          Text(
            selectedDate == null
                ? 'Any date'
                : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white : const Color(0xFF353535),
            ),
          ),
        ],
      ),
    );
  }
}
