import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.isDarkMode,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.imageUrl,
    this.onCtaPressed,
    this.lightModeTextColor,
    this.darkModeTextColor,
    this.lightModeButtonColor,
    this.darkModeButtonColor,
    this.lightModeButtonTextColor,
    this.darkModeButtonTextColor,
    this.horizontalPadding = 0,
    this.maxContentWidth = 720,
  });

  final bool isDarkMode;
  final String title;
  final String subtitle;
  final String ctaText;
  final String imageUrl;
  final VoidCallback? onCtaPressed;
  final Color? lightModeTextColor;
  final Color? darkModeTextColor;
  final Color? lightModeButtonColor;
  final Color? darkModeButtonColor;
  final Color? lightModeButtonTextColor;
  final Color? darkModeButtonTextColor;
  final double horizontalPadding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color overlayColor = isDarkMode
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.4);
    final Color titleColor = isDarkMode
        ? (darkModeTextColor ?? Colors.white)
        : (lightModeTextColor ?? const Color(0xFF111827));
    final Color subtitleColor = isDarkMode
        ? (darkModeTextColor ?? Colors.white).withOpacity(0.92)
        : (lightModeTextColor ?? const Color(0xFF1F2937)).withOpacity(0.9);
    final Color buttonBgColor = isDarkMode
        ? (darkModeButtonColor ?? Colors.white)
        : (lightModeButtonColor ?? const Color(0xFF111827));
    final Color buttonTextColor = isDarkMode
        ? (darkModeButtonTextColor ?? const Color(0xFF111827))
        : (lightModeButtonTextColor ?? Colors.white);

    return SizedBox(
      height: 420,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: overlayColor),
            ),
          ),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            foregroundColor: buttonTextColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: onCtaPressed,
                          child: Text(
                            ctaText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
  );
  }
}

