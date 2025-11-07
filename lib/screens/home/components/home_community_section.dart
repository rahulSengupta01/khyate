import 'dart:math' as math;

import 'package:flutter/material.dart';

class HomeCommunitySection extends StatefulWidget {
  const HomeCommunitySection({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  State<HomeCommunitySection> createState() => _HomeCommunitySectionState();
}

class _HomeCommunitySectionState extends State<HomeCommunitySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const String _communityImage =
      'https://images.unsplash.com/photo-1527169402691-feff5539e52c?auto=format&fit=crop&w=1600&q=80';

  final List<String> _bullets = const [
    "OutBox isn't just a brand — it's a movement powered by people.",
    'Our community is made of doers, dreamers, and disruptors united by living outside the box.',
    "From bold workouts to calming wellness sessions, you're part of a tribe that values courage, creativity, and connection.",
    'Here, everyone belongs. Everyone grows. And everyone moves forward together.',
    'Join us and feel how liberating it is to break free and live fully.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color headingColor =
        widget.isDarkMode ? Colors.white : const Color(0xFFF7F3EE);
    final Color bodyColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFFEFE3D7);

    final List<Color> gradientColors = widget.isDarkMode
        ? const [
            Color(0xFF2D2826),
            Color(0xFF1F1B19),
          ]
        : const [
            Color(0xFF8F8176),
            Color(0xFF74665E),
          ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 56.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth > 900;
            final EdgeInsets contentPadding = EdgeInsets.only(
              right: isWide ? 24.0 : 0.0,
            );

            final Widget textColumn = FadeSlideTransition(
              controller: _controller,
              offset: const Offset(0.0, 0.12),
              delay: const Duration(milliseconds: 120),
              child: Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'The OutBox Community',
                      style: textTheme.headlineMedium?.copyWith(
                        color: headingColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 72,
                      height: 3,
                      decoration: BoxDecoration(
                        color: bodyColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._bullets.map(
                      (bullet) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: Color(0xFFE0D1C7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                bullet,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: bodyColor,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            final Widget mediaCard = FadeSlideTransition(
              controller: _controller,
              offset: const Offset(0.12, 0.0),
              delay: const Duration(milliseconds: 220),
              child: AspectRatio(
                aspectRatio: isWide ? 16 / 9 : 4 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          _communityImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '“Session was inspiring and full of energy.”',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  '— Balaji',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFFFC857),
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: textColumn),
                  const SizedBox(width: 32),
                  Expanded(flex: 5, child: mediaCard),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textColumn,
                const SizedBox(height: 32),
                mediaCard,
              ],
            );
          },
        ),
      ),
    );
  }
}

class FadeSlideTransition extends StatelessWidget {
  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.child,
    required this.offset,
    this.delay = Duration.zero,
  });

  final AnimationController controller;
  final Widget child;
  final Offset offset;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double progress = (controller.value -
                (delay.inMilliseconds / controller.duration!.inMilliseconds))
            .clamp(0.0, 1.0);
        final double curved = Curves.easeOutCubic.transform(progress);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(-offset.dx, -offset.dy) * math.max(1 - curved, 0),
            child: child,
          ),
        );
      },
    );
  }
}

