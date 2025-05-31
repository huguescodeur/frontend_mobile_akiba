import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/constants/images.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/widgets/components/custom_button.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  static const String idView = "onboardingview";

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Gère ton argent simplement',
      'subtitle':
          'Dépose, retire ou utilise ton argent en toute sécurité depuis ton mobile.',
      'image': Images.onboarding1,
    },
    {
      'title': 'Atteins tes objectifs et gagne des récompenses',
      'subtitle':
          'Relève des défis, épargne petit à petit et sois récompensé pour tes efforts.',
      'image': Images.onboarding2,
    },
    {
      'title': 'Suis tes dépenses et économise mieux',
      'subtitle':
          'Visualise où part ton argent et adopte de meilleures habitudes.',
      'image': Images.onboarding3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      navigateWithTransition(
        context: context,
        page: LoginView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    }
  }

  void _skipOnboarding() {
    _pageController.animateToPage(
      onboardingData.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              !(_currentPage == onboardingData.length - 1)
                  ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Passer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textSecondaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  : Container(),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                // Text content section at the top
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Title
                                      SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, -0.3),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: const Interval(
                                              0.0,
                                              0.6,
                                              curve: Curves.easeOut,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          onboardingData[index]['title']!,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 28,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textLight,
                                            height: 1.3,
                                          ),

                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      Gap(16),

                                      // Subtitle
                                      SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, -0.2),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: const Interval(
                                              0.2,
                                              0.8,
                                              curve: Curves.easeOut,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          onboardingData[index]['subtitle']!,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w300,
                                            fontSize: 16,
                                            color: AppColors.textSecondaryLight,
                                            height: 1.5,
                                          ),

                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Illustration section
                                Expanded(
                                  flex: 4,
                                  child: Center(
                                    child: TweenAnimationBuilder<double>(
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: 0.8 + (value * 0.2),
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 320,
                                              maxHeight: 320,
                                            ),
                                            child: Image.asset(
                                              onboardingData[index]['image']!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Center(
                                                  child: Text(
                                                    'Image ${index + 1}',
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // ? Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? AppColors.primaryLight
                                    : AppColors.backgroundLightGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    Gap(32),

                    // ? Suivant/Commencer button
                    CustomButton(
                      label:
                          _currentPage == onboardingData.length - 1
                              ? 'Commencer'
                              : 'Suivant',
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
