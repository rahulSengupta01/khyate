import 'package:flutter/material.dart';

class HomeValuesSection extends StatefulWidget {
  const HomeValuesSection({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  State<HomeValuesSection> createState() => _HomeValuesSectionState();
}

class _HomeValuesSectionState extends State<HomeValuesSection> {
  late final PageController _controller;
  int _currentPage = 0;

  static const List<_ValueCardData> _values = [
    _ValueCardData(
      title: 'Courage',
      description:
          'We step beyond comfort zones and meet every challenge with fearless determination.',
      imageUrl:
          'https://images.unsplash.com/photo-1571019613575-d2aa2408333d?auto=format&fit=crop&w=1600&q=80',
      backgroundColor: Color(0xFFFDEBDD),
      textColor: Color(0xFF1F2933),
      accentColor: Color(0xFFE7A97E),
    ),
    _ValueCardData(
      title: 'Creativity',
      description:
          'Innovation fuels our approach, encouraging new ways to move, think, and celebrate life.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80',
      backgroundColor: Color(0xFFFF5B5B),
      textColor: Colors.white,
      accentColor: Color(0xFFFFA7A7),
    ),
    _ValueCardData(
      title: 'Community',
      description:
          "More than a brand — OutBox is a vibrant community where connection and support are real.",
      imageUrl:
          'https://images.unsplash.com/photo-1508786953046-0bb337221d97?auto=format&fit=crop&w=1600&q=80',
      backgroundColor: Color(0xFFC28A3B),
      textColor: Colors.white,
      accentColor: Color(0xFFF0D6A8),
    ),
    _ValueCardData(
      title: 'Authenticity',
      description:
          'We celebrate individuality and genuine expression in everything we do together.',
      imageUrl:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=1600&q=80',
      backgroundColor: Color(0xFF10D8C4),
      textColor: Colors.white,
      accentColor: Color(0xFFA7F5EB),
    ),
    _ValueCardData(
      title: 'Empowerment',
      description:
          'We equip every member to own their health, wellness, and happiness with confidence.',
      imageUrl:
          'https://images.unsplash.com/photo-1526403220839-74aa1de58e9a?auto=format&fit=crop&w=1600&q=80',
      backgroundColor: Color(0xFF1F2330),
      textColor: Colors.white,
      accentColor: Color(0xFFF7F3EE),
      borderColor: Color(0xFFF7F3EE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color descriptionColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.9)
        : const Color(0xFF1F2933).withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.only(right: 24.0, top: 48.0, bottom: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              'At OutBox, our values are the foundation of everything we do. They guide how we move, create, and connect.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: descriptionColor,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 820;
              final double height = isDesktop ? 420 : 380;

              return Column(
                children: [
                  SizedBox(
                    height: height,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _values.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final data = _values[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 0 : 12.0,
                            right: 12.0,
                          ),
                          child: _ValueCard(
                            data: data,
                            isDarkMode: widget.isDarkMode,
                            elevation: index == _currentPage ? 18 : 6,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _values.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 8,
                        width: _currentPage == index ? 28 : 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _values[index].accentColor
                              : descriptionColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ValueCardData {
  const _ValueCardData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    this.borderColor,
  });

  final String title;
  final String description;
  final String imageUrl;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final Color? borderColor;
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.data,
    required this.isDarkMode,
    required this.elevation,
  });

  final _ValueCardData data;
  final bool isDarkMode;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasBorder = data.borderColor != null;

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: data.backgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: hasBorder ? Border.all(color: data.borderColor!, width: 1.6) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(isDarkMode ? 0.45 : 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Text(
                        data.title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: data.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Our Value',
                        style: textTheme.labelLarge?.copyWith(
                          color: data.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      data.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: data.textColor.withOpacity(0.92),
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Outside the Box',
                          style: textTheme.labelLarge?.copyWith(
                            color: data.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: data.textColor.withOpacity(0.8),
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
  }
}

