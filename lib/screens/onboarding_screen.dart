import 'package:event/app_theme.dart';
import 'package:event/components/custom_elevated_button.dart';
import 'package:event/models/onboarding_model.dart';
import 'package:event/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  void _nextPage() {
    if (currentPage < OnboardingModel.onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.03),
            Image.asset(
              'assets/Logo.png',
              height: size.height * 0.2,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingModel.onboardingPages.length,
                onPageChanged: (index) => setState(() => currentPage = index),
                itemBuilder: (context, index) {
                  final page = OnboardingModel.onboardingPages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Image.asset(
                            page.imageAsset,
                            fit: BoxFit.fill,
                            height: size.height * 0.3,
                            width: double.infinity,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          page.title,
                          style: textTheme.titleLarge!.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          page.description,
                          style: textTheme.titleSmall!.copyWith(
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: size.height * 0.05,
                left: 24,
                right: 24,
              ),
              child: currentPage == 0
                  ? CustomElevatedButton(
                      textElevatedButton: "Let's Start",
                      onPressed: _nextPage,
                    )
                  : Row(
                      children: [
                        // Back button
                        if (currentPage > 0)
                          TextButton(
                            onPressed: _previousPage,
                            child: Text(
                              'Back',
                              style: textTheme.headlineSmall!.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              OnboardingModel.onboardingPages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentPage == index
                                      ? AppTheme.primary
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _nextPage,
                          child: Text(
                            currentPage ==
                                    OnboardingModel.onboardingPages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: textTheme.headlineSmall!.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
