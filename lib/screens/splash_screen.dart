import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/widgets.dart';
import 'admin/admin_dashboard.dart';
import 'main_nav.dart';
import 'auth/login_screen.dart';

// ─── Cinematic Splash Screen (Strict Theme Compliant) ────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // System UI Overlay configuration matched to AppColors.bg0
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.bg0,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _runEntranceSequence();
  }

  Future<void> _runEntranceSequence() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      HapticFeedback.mediumImpact();
      final savedEmail = await AuthService().getLoggedInUserEmail();
      if (savedEmail != null) {
        final user = await BackendService.instance.getUserProfile(savedEmail);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => user?.role == UserRole.admin
                ? const AdminDashboard()
                : MainNav(isAdmin: user?.role == UserRole.admin),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          // ─── ROUTE 1 FIXED: Splash now goes to Onboarding ───
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Faint background glow (Mapped to bg1)
          Container(
            width: MediaQuery.of(context).size.width * 1.2,
            height: MediaQuery.of(context).size.width * 1.2,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg1,
            ),
          ),

          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 4),

              // --- LOGO ---
              SizedBox(
                height: 180.0,
                width: 180.0,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.change_history_rounded,
                        size: 120.0, color: AppColors.cyan); // Clean fallback
                  },
                ),
              ),
              const SizedBox(height: 32.0),

              // --- TITLE ---
              Text(
                'GAMEARENA',
                style: AppText.displayLg.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10.0),

              // --- SUBTITLE ---
              Text(
                'TOURNAMENT PLATFORM',
                style: AppText.label.copyWith(
                  letterSpacing: 2.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 3),

              // --- LOADING INDICATOR ---
              const SizedBox(
                height: 40.0,
                width: 40.0,
                child: CircularProgressIndicator(
                  color: AppColors.cyan, // Strictly branded
                  strokeWidth: 3.5,
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modern Glassmorphic Onboarding Screen ───────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;

  // Stripped out all unapproved gradients and mapped directly to brand colors
  final List<_OnboardData> _pages = const [
    _OnboardData(
      icon: Icons.emoji_events_rounded,
      title: 'COMPETE AT THE TOP',
      subtitle:
          'Join official esports tournaments across multiple titles. From MLBB to PUBG — find your arena.',
      glowColor: AppColors.cyan,
    ),
    _OnboardData(
      icon: Icons.groups_rounded,
      title: 'REGISTER YOUR TEAM',
      subtitle:
          'Build your squad, add your roster with verified player profiles, and represent your team on the big stage.',
      glowColor: AppColors.purple,
    ),
    _OnboardData(
      icon: Icons.explore_rounded,
      title: 'EXPLORE THE SCENE',
      subtitle:
          'Follow tournaments, view team rosters, track brackets, and discover rising stars in the competitive ecosystem.',
      glowColor: AppColors.pink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        // ─── ROUTE 2 FIXED: Skip and Finish now go to Login ───
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // Dynamic Ambient Background mapped to the current page glow
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: _currentPageIndex == 1 ? -50.0 : 100.0,
            left: _currentPageIndex == 0
                ? -100.0
                : (_currentPageIndex == 2 ? 100.0 : -50.0),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90.0, sigmaY: 90.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 400.0,
                height: 400.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pages[_currentPageIndex].glowColor.withOpacity(0.08),
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GAMEARENA',
                          style: AppText.heading.copyWith(
                              letterSpacing: 2.0, fontWeight: FontWeight.w900),
                        ),
                        TextButton(
                          onPressed: _navigateToMain,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: Text(
                            'SKIP',
                            style: AppText.label.copyWith(
                                color: AppColors.textMuted, letterSpacing: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Content Slider
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => _currentPageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return _OnboardPageView(data: _pages[index]);
                      },
                    ),
                  ),

                  // Footer Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 48.0),
                    child: Column(
                      children: [
                        // Animated Page Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              width: index == _currentPageIndex ? 28.0 : 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: index == _currentPageIndex
                                    ? _pages[_currentPageIndex].glowColor
                                    : AppColors.bg3,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: index == _currentPageIndex
                                    ? [
                                        BoxShadow(
                                            color: _pages[_currentPageIndex]
                                                .glowColor
                                                .withOpacity(0.4),
                                            blurRadius: 8.0)
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40.0),

                        // Primary Action Component
                        SizedBox(
                          width: double.infinity,
                          child: GlowButton(
                            label: _currentPageIndex == _pages.length - 1
                                ? 'INITIALIZE SYSTEM'
                                : 'NEXT PROTOCOL',
                            height: 56.0,
                            // Uses the signature Brand Gradient for the final step!
                            gradient: _currentPageIndex == _pages.length - 1
                                ? AppColors.gradientBrand
                                : null,
                            color: _currentPageIndex == _pages.length - 1
                                ? null
                                : _pages[_currentPageIndex].glowColor,
                            onTap: _nextPage,
                          ),
                        ),

                        const SizedBox(height: 24.0),

                        // Authentication Deep Link
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Already have clearance? ',
                                style: AppText.body
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: AppText.body.copyWith(
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _navigateToLogin,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models & Sub-Views ─────────────────────────────────────────────────

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color glowColor;

  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.glowColor,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardData data;

  const _OnboardPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Frosted Glass Orb
                  Container(
                    width: 180.0,
                    height: 180.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bg2.withOpacity(0.4),
                      border: Border.all(
                          color: data.glowColor.withOpacity(0.3), width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: data.glowColor.withOpacity(0.15),
                          blurRadius: 60.0,
                          spreadRadius: 10.0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Center(
                          child: Icon(data.icon,
                              size: 80.0, color: data.glowColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60.0),

                  // Typography Group
                  Text(
                    data.title,
                    style: AppText.displaySm.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    data.subtitle,
                    style: AppText.body.copyWith(
                      fontSize: 15.0,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
