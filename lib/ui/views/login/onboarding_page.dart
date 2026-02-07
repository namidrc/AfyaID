import 'package:afya_id/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:afya_id/ui/styles/app_colors.dart';
import 'package:afya_id/domain/utils/general_utils.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'Emergency Management',
      description:
          'Quickly access patient records in emergency situations with our advanced biometric scanning system.',
      icon: Icons.emergency,
      color: AppColors.emergencyRed,
    ),
    OnboardingContent(
      title: 'Patient Monitoring',
      description:
          'View and update vital signs and medical information in real time.',
      icon: Icons.monitor_heart,
      color: AppColors.patientBlue,
    ),
    OnboardingContent(
      title: 'Consultation Log',
      description:
          'Keep a complete record of all access and consultations for enhanced traceability.',
      icon: Icons.history_edu,
      color: AppColors.primaryTeal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateToLogin(),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildIndicator(index == _currentPage),
              ),
            ),

            const SizedBox(height: 40),

            // Navigation button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GeneralUtils().generalButton(
                backColor: _pages[_currentPage].color,
                text: _currentPage == _pages.length - 1 ? 'Start' : 'Next',
                tapAction: () {
                  if (_currentPage == _pages.length - 1) {
                    _navigateToLogin();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated container
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: content.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, size: 100, color: content.color),
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            content.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _pages[_currentPage].color : AppColors.grey2,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToLogin() {
    context.push(RoutesPaths.login);
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
