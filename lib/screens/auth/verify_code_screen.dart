import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart'; // ─── CONNECTED REAL ENGINE TERMINAL ───
import '../main_nav.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
import 'complete_profile_screen.dart'; // ─── NEW ROUTE FOR GOOGLE USERS ───

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final bool isSignup;
  final bool isAdmin;
  final bool isReset;

  // ─── NEW FLAG: TELLS US IF THIS IS A BRAND NEW GOOGLE ACCOUNT ───
  final bool isGoogleNewUser;

  // ─── REGISTRATION PARAMETERS HOOKED FOR PERSISTENCE ───
  final String name;
  final String country;
  final String password;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    this.isSignup = false,
    this.isAdmin = false,
    this.isReset = false,
    this.isGoogleNewUser = false, // Defaults to false for standard logins
    this.name = '',
    this.country = '',
    this.password = '',
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen>
    with SingleTickerProviderStateMixin {
  String _otpBuffer = '';
  bool _loading = false;
  int _secondsRemaining = 54;
  Timer? _timer;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 54;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() async {
    if (_secondsRemaining > 0) return;
    HapticFeedback.lightImpact();

    try {
      // Ask Firebase to generate and send a new code
      await AuthService().sendVerificationCode(widget.email);
      setState(() {
        _startTimer();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend: $e')),
      );
    }
  }

  void _onKeyPress(String value) {
    if (_loading) return;
    HapticFeedback.selectionClick();

    setState(() {
      if (value == '⌫') {
        if (_otpBuffer.isNotEmpty) {
          _otpBuffer = _otpBuffer.substring(0, _otpBuffer.length - 1);
        }
      } else if (_otpBuffer.length < 4) {
        _otpBuffer += value;
        if (_otpBuffer.length == 4) {
          _verify();
        }
      }
    });
  }

  // ─── THE NEW FULL-STACK VERIFICATION LOGIC ───
  void _verify() async {
    setState(() => _loading = true);

    try {
      // 1. Check if the code matches what is in Cloud Firestore
      bool isMatch = await AuthService().checkCode(widget.email, _otpBuffer);

      if (!isMatch) {
        HapticFeedback.vibrate();
        setState(() {
          _loading = false;
          _otpBuffer = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please try again.')),
        );
        return;
      }

      // 2. Code is correct! Execute the correct Firebase Database Action
      if (widget.isGoogleNewUser) {
        // DO NOTHING IN DATABASE YET! Just route them to the profile page.
      } else if (widget.isSignup) {
        await AuthService().registerUser(
          email: widget.email,
          name: widget.name,
          country: widget.country,
          password: widget.password,
        );
        // ─── ADDED PERSISTENCE SAVE FOR NEW ACCOUNTS ───
        await AuthService().saveUserSession(widget.email);
      } else if (!widget.isReset) {
        // Standard Login or Google Login
        bool isGoogleAuth = widget.password.isEmpty;
        await AuthService()
            .loginUser(widget.email, widget.password, isGoogle: isGoogleAuth);
        // ─── ADDED PERSISTENCE SAVE FOR LOGGED IN ACCOUNTS ───
        await AuthService().saveUserSession(widget.email);
      }

      if (!mounted) return;
      HapticFeedback.successNotification();

      // 3. Navigate to the right place based on their status
      if (widget.isReset) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(email: widget.email)),
        );
      } else if (widget.isGoogleNewUser) {
        // ─── ROUTE BRAND NEW GOOGLE USERS HERE ───
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(email: widget.email)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNav()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.vibrate();
      setState(() {
        _loading = false;
        _otpBuffer = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _handleBackNavigation() {
    if (!mounted) return;

    if (widget.isReset) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      );
    } else if (widget.isSignup || widget.isGoogleNewUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: ClipPath(
              clipper: TopArchClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _handleBackNavigation,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2C3344)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mark_email_read_outlined,
                                size: 64, color: Color(0xFF00E5FF)),
                            const SizedBox(height: 24),
                            const Text(
                              'Check your email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We sent a 4-digit code to\n${widget.email}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF7A8498),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // OTP Display Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                bool isFilled = index < _otpBuffer.length;
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isFilled
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF1A1F2C),
                                    border: Border.all(
                                      color: isFilled
                                          ? const Color(0xFF00E5FF)
                                          : const Color(0xFF2C3344),
                                      width: 2,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),

                            // Loading Indicator or Resend Logic
                            if (_loading)
                              const CircularProgressIndicator(
                                  color: Color(0xFF00E5FF))
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _secondsRemaining > 0
                                        ? 'Resend code in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                                        : "Didn't receive the code?",
                                    style: const TextStyle(
                                        color: Color(0xFF7A8498), fontSize: 14),
                                  ),
                                  if (_secondsRemaining == 0) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: _resendCode,
                                      child: const Text(
                                        'Resend',
                                        style: TextStyle(
                                          color: Color(0xFF00E5FF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            const SizedBox(height: 48),

                            // Custom Keypad
                            if (!_loading)
                              Column(
                                children: [
                                  _buildKeypadRow(['1', '2', '3']),
                                  const SizedBox(height: 16),
                                  _buildKeypadRow(['4', '5', '6']),
                                  const SizedBox(height: 16),
                                  _buildKeypadRow(['7', '8', '9']),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Expanded(child: SizedBox()),
                                      Expanded(child: _buildKeypadButton('0')),
                                      Expanded(child: _buildKeypadButton('⌫')),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children:
          keys.map((k) => Expanded(child: _buildKeypadButton(k))).toList(),
    );
  }

  Widget _buildKeypadButton(String value) {
    return InkWell(
      onTap: () => _onKeyPress(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class TopArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 60);
    final Offset controlPoint = Offset(size.width / 2, size.height + 20);
    final Offset endPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
