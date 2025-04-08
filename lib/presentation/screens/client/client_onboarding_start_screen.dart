// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardingStartScreen extends ConsumerStatefulWidget {
  const OnboardingStartScreen({super.key});

  @override
  ConsumerState<OnboardingStartScreen> createState() =>
      _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends ConsumerState<OnboardingStartScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goBackToStart() {
    final router = ref.read(appRouterProvider);
    router.pushReplacement('/client-start');
  }

  Future<bool> _onWillPop() async {
    _goBackToStart();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final router = ref.read(appRouterProvider);
    final isDarkMode = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: _goBackToStart,
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    _buildOnboardingPage(
                      context,
                      title: "¿Buscando las mejores ofertas?",
                      subtitle: "¡No te desesperes!",
                      description:
                          "Tenemos un montón de descuentos y ofertas para ti que no puedes desaprovechar. ;)",
                      imagePath:
                          "assets/images/onboarding1_bombastik_removedbg.png",
                    ),
                    _buildOnboardingPage(
                      context,
                      title: "¡Fácil, rápido y seguro!",
                      subtitle: "La mejor app de ahorro sin dudar.",
                      description:
                          "Navega y ordena sin problemas desde la comodidad de tu sofá.",
                      imagePath: "assets/images/miss_carrito_sinfondo.png",
                    ),
                    _buildOnboardingPage(
                      context,
                      title: "¡Pide en pocos pasos!",
                      subtitle: "",
                      description:
                          "Encuentra los mejores descuentos y las ofertas más llamativas.",
                      imagePath: "assets/images/hombre_cargandobolsas.png",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: smooth_page_indicator.SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: smooth_page_indicator.ExpandingDotsEffect(
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.onSurface.withOpacity(0.2),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPageIndex < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      router.push('/client-signin');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPageIndex < 2 ? "Continuar" : "¡Registrate!",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color:
                          isDarkMode
                              ? theme.colorScheme.onBackground
                              : theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String imagePath,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 250, fit: BoxFit.contain),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
