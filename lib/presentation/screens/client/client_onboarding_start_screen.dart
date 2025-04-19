// ignore_for_file: deprecated_member_use

import 'package:bombastik/config/router/app_router.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingStartScreen extends ConsumerStatefulWidget {
  const OnboardingStartScreen({super.key});

  @override
  ConsumerState<OnboardingStartScreen> createState() =>
      _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends ConsumerState<OnboardingStartScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;
  bool _isButtonPressed = false;

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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDarkMode
                      ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
                      : [
                        AppColors.lightGradientStart,
                        AppColors.lightGradientEnd,
                      ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _goBackToStart,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: smooth_page_indicator.SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: smooth_page_indicator.ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.3),
                      dotHeight: 10,
                      dotWidth: 10,
                      spacing: 8,
                      expansionFactor: 3,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isButtonPressed = true),
                    onTapUp: (_) {
                      setState(() => _isButtonPressed = false);
                      if (_currentPageIndex < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        router.push('/client-signin');
                      }
                    },
                    onTapCancel: () => setState(() => _isButtonPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF9800), // Naranja cálido
                            const Color(0xFFF57C00), // Naranja más profundo
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          if (!_isButtonPressed)
                            BoxShadow(
                              color: const Color(0xFFF57C00).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPageIndex < 2 ? "Continuar" : "¡Regístrate!",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn().scale(delay: 600.ms),
                ),
              ],
            ),
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 32),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3, delay: 200.ms),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(begin: 0.3, delay: 300.ms),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn().scale(delay: 400.ms),
        ],
      ),
    );
  }
}
