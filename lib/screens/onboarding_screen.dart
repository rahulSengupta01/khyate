import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int pageIndex = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'headline': 'Elegant Restraint',
      'subtitle': 'Experience minimal luxury. UAE culture. Maximum efficiency.',
      'asset': 'assets/pattern1.png',
    },
    {
      'headline': 'Seamless Authentication',
      'subtitle': 'Login, signup, OTP or Google. All with one elegant UI.',
      'asset': 'assets/pattern2.png',
    },
    {
      'headline': 'Crafted For You',
      'subtitle': 'Personalized dashboards and workflows for tailors, admins, and more.',
      'asset': 'assets/pattern3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => setState(() => pageIndex = i),
                itemCount: pages.length,
                itemBuilder: (_, i) {
                  final pg = pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pg['asset'] != null)
                        Image.asset(pg['asset'], height: 180),
                      const SizedBox(height: 36),
                      Text(pg['headline'], style: TextStyle(
                        fontSize: 24, color: Color(0xFFC5A572), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 18),
                      Text(pg['subtitle'], style: TextStyle(
                        fontSize: 16, color: Color(0xFF1A2332))),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: pageIndex == i ? 14 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pageIndex == i ? const Color(0xFFC5A572) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC5A572),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                // finished onboarding → Go to LoginScreen
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: Text(pageIndex == pages.length-1 ? 'Get Started' : 'Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
