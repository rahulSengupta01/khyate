import 'package:flutter/material.dart';

class FitnessSession {
  final String label;
  final IconData icon; // Replace with asset widgets for custom icons
  final VoidCallback onTap;
  FitnessSession({required this.label, required this.icon, required this.onTap});
}

class FitnessSessionsGrid extends StatelessWidget {
  final List<FitnessSession> sessions;
  final bool isDarkMode;
  /// Override section title (e.g. "Top Wellness Sessions" on Wellness page).
  final String? sectionTitle;
  /// When set, use this as brand accent for icon circle gradient and icon color (e.g. #AD8654 for Wellness).
  final Color? accentColor;

  const FitnessSessionsGrid({
    super.key,
    required this.sessions,
    required this.isDarkMode,
    this.sectionTitle,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1A2332);
    // Use accentColor for Wellness (#AD8654) with horizontal gradient to darker shade; otherwise Fitness teal/green
    final Color iconBgStart = accentColor != null
        ? accentColor!
        : (isDarkMode ? const Color(0xFF2D7D7A) : const Color(0xFF21B998));
    final Color iconBgEnd = accentColor != null
        ? Color.lerp(accentColor!, Colors.black, 0.35) ?? accentColor!
        : (isDarkMode ? const Color(0xFFC5A572) : const Color(0xFF0097B2));
    final Color iconColor = accentColor != null
        ? Colors.white
        : (isDarkMode ? Colors.white70 : const Color(0xFF1A2332));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle ?? "Top Fitness Sessions",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 28,
            crossAxisSpacing: 28,
            childAspectRatio: 1.1,
            physics: NeverScrollableScrollPhysics(),
            children: sessions.map((session) {
              return GestureDetector(
                onTap: session.onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            iconBgStart,
                            iconBgEnd,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      width: 96,
                      height: 96,
                      child: Center(
                        child: Icon(
                          session.icon,
                          size: 50,
                          color: iconColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      session.label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
