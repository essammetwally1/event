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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30),
            Image.asset('assets/Logo.png', height: 171),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingModel.onboardingPages.length,
                onPageChanged: (index) => setState(() => currentPage = index),
                itemBuilder: (context, index) {
                  final page = OnboardingModel.onboardingPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          page.imageAsset,
                          height: 250,
                          width: double.infinity,
                        ),
                        SizedBox(height: 20),
                        Text(
                          page.title,
                          style: textTheme.titleLarge!.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.description,
                          style: textTheme.titleMedium!.copyWith(
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            currentPage == 0
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomElevatedButton(
                      textElevatedButton: "Let's Start",
                      onPressed: _nextPage,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20,
                    ),
                    child: Row(
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
                          const SizedBox(
                            width: 60,
                          ), // keeps spacing when no Back button
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
                            'Next',
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
