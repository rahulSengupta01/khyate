import 'package:flutter/material.dart';

class HomeLogoStorySection extends StatelessWidget {
  const HomeLogoStorySection({super.key, required this.isDarkMode});

  final bool isDarkMode;

  static const String _backgroundImageUrl =
      'https://images.unsplash.com/photo-1526401485004-46910ecc8e51?auto=format&fit=crop&w=1600&q=80';
  static const String _logoImageUrl =
      'https://images.unsplash.com/photo-1531853121101-cd38b97c5412?auto=format&fit=crop&w=600&q=80';

  Color _overlayColor() {
    return isDarkMode
        ? Colors.black.withOpacity(0.65)
        : const Color(0xFF5B4C43).withOpacity(0.55);
  }

  Color _primaryTextColor() {
    return isDarkMode ? Colors.white : const Color(0xFFF4ECE4);
  }

  Color _accentTextColor() {
    return isDarkMode ? const Color(0xFFF7F3EE) : const Color(0xFFEAD7C8);
  }

  Color _cardBackgroundColor() {
    return isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color primaryText = _primaryTextColor();
    final Color accentText = _accentTextColor();

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _backgroundImageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: _overlayColor()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 60.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Our Logo Story',
                      style: textTheme.headlineSmall?.copyWith(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 3,
                      decoration: BoxDecoration(
                        color: accentText,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'OutBox was born to break the mold — redefining how people experience movement, health, and connection.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: primaryText.withOpacity(0.9),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          _logoImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Our name means operating outside the box, both literally and figuratively. We bring fitness, wellness, and community experiences to you — transforming everyday spaces into places for energy, balance, and connection.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: primaryText.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Our logo captures this spirit',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: accentText,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth > 700;
                        final cards = [
                          _LogoCard(
                            icon: Icons.circle_outlined,
                            title: 'Wheels in Motion',
                            description:
                                'Our logo represents constant movement and progress, driving you forward.',
                            backgroundColor: _cardBackgroundColor(),
                            textColor: primaryText,
                          ),
                          _LogoCard(
                            icon: Icons.account_tree_outlined,
                            title: 'Structure Meets Creativity',
                            description:
                                'A balance between discipline and imagination in every experience.',
                            backgroundColor: _cardBackgroundColor(),
                            textColor: primaryText,
                          ),
                          _LogoCard(
                            icon: Icons.eco_outlined,
                            title: 'Space to Breathe',
                            description:
                                'Freedom to express, grow, and thrive in your own way.',
                            backgroundColor: _cardBackgroundColor(),
                            textColor: primaryText,
                          ),
                        ];

                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: cards
                                .map((card) => Expanded(child: card))
                                .expand((widget) sync* {
                                  yield widget;
                                  if (cards.last != widget) {
                                    yield const SizedBox(width: 24);
                                  }
                                })
                                .toList(),
                          );
                        }

                        return Column(
                          children: [
                            ...cards.expand((card) => [card, const SizedBox(height: 16)]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'OutBox lives through three sub-brands: Fitness, Wellness, and Liveness — all designed to help you live fully, wherever you are.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: primaryText.withOpacity(0.9),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'OutBox — Built to Move.',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: accentText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: textColor.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

