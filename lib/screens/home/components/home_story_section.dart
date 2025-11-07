import 'package:flutter/material.dart';

class HomeStorySection extends StatelessWidget {
  const HomeStorySection({super.key, required this.isDarkMode});

  final bool isDarkMode;

  static const String _experienceImageUrl =
      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1400&q=80';

  Color _cardColor(BuildContext context) {
    if (isDarkMode) {
      return Colors.white.withOpacity(0.07);
    }
    return const Color(0xFFF3EFE9);
  }

  Color _quoteAccentColor() {
    return isDarkMode ? const Color(0xFFF7F3EE) : const Color(0xFF3B2A22);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color baseTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2933);
    final Color emphasisColor = isDarkMode ? const Color(0xFFF7F3EE) : const Color(0xFF3B2A22);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 20,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Outbox is a lifestyle brand ',
                  style: textTheme.titleMedium?.copyWith(
                    color: baseTextColor,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'founded on the belief that life is meant to be lived outside the box — boldly, creatively, and without limits.',
                      style: TextStyle(color: emphasisColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'We design and deliver unique experiences across fitness, wellness, and community gatherings, empowering individuals to break free from routine, challenge the status quo, and express their authentic selves.',
                style: textTheme.bodyLarge?.copyWith(
                  color: baseTextColor.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: _cardColor(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '"Whether through dynamic classes, mindful wellness sessions, or vibrant social events, Outbox inspires you to move, grow, and connect in ways that spark transformation and joy."',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: emphasisColor,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'More than a brand, Outbox is a mindset — a movement for those who dare to live fully and fearlessly.',
            style: textTheme.bodyLarge?.copyWith(
              color: baseTextColor,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 880;
              final Widget image = ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    _experienceImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              );

              final Widget narrative = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Outbox was born from one bold thought: What if we could live outside the box?',
                    style: textTheme.titleMedium?.copyWith(
                      color: emphasisColor,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Our founder set out to build a brand that breaks routine — one that celebrates movement, creativity, and self-expression.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: baseTextColor.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _cardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"',
                          style: textTheme.headlineMedium?.copyWith(
                            color: emphasisColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your only limit is the one you set yourself.',
                            style: textTheme.titleMedium?.copyWith(
                              color: emphasisColor,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "That mindset is at the heart of everything we do. Outbox isn't just classes or products — it's a community of doers and dreamers who believe life is meant to be lived fully, freely, and fearlessly.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: baseTextColor.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: image),
                    const SizedBox(width: 32),
                    Expanded(flex: 5, child: narrative),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  const SizedBox(height: 24),
                  narrative,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

