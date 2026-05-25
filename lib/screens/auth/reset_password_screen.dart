import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart';
import 'reset_success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, this.email = ''});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;
  bool _loading = false;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode.addListener(() {
      setState(() => _isPasswordFocused = _passwordFocusNode.hasFocus);
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(
          () => _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus);
    });

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
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _loading = true);

    try {
      await AuthService().resetPassword(
        widget.email,
        _passwordController.text.trim(),
      );
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResetSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error updating security parameters: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F141E), // Match exact deep background tone
      body: Stack(
        children: [
          // --- FIGMA ARCH GRADIENT BACKGROUND ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: ResetTopArchClipper(),
              child: Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF141C2B), Color(0xFF111724)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        // --- BACK NAVIGATION ARROW CONTROL ---
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2535),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chevron_left_rounded,
                                  size: 28, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // --- LOCK ICON EMBLEM SHIELD RINGS ---
                        Center(
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161D2B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF222C41),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2D3B54)
                                        .withOpacity(0.6),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock_open_rounded,
                                    color: Color(
                                        0xFFFF007A), // Hot magenta security ring accents
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- HEADING HEADER BLOCK ---
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create a strong, completely secure new password\nto finalize account access recovery.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7588),
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- NEW PASSWORD INPUT ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'NEW PASSWORD',
                            style: TextStyle(
                              color: Color(0xFF717D96),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _isNewObscured,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          cursorColor: const Color(0xFF00E5FF),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be minimum 6 characters';
                            }
                            return null;
                          },
                          decoration: _buildInputDecoration(
                            hintText: '••••••',
                            isFocused: _isPasswordFocused,
                            obscureText: _isNewObscured,
                            onObscureToggle: () => setState(
                                () => _isNewObscured = !_isNewObscured),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- CONFIRM PASSWORD INPUT ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'CONFIRM NEW PASSWORD',
                            style: TextStyle(
                              color: Color(
                                  0xFF00E5FF), // Active cyan highlighted text label tracking
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          obscureText: _isConfirmObscured,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _resetPassword(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          cursorColor: const Color(0xFF00E5FF),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: _buildInputDecoration(
                            hintText: '••••••',
                            isFocused: _isConfirmPasswordFocused,
                            obscureText: _isConfirmObscured,
                            onObscureToggle: () => setState(
                                () => _isConfirmObscured = !_isConfirmObscured),
                          ),
                        ),

                        const SizedBox(height: 44),

                        // --- BRAND SIGNATURE UPGRADED CTAS GRADIENT BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF00E5FF)))
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE8258F), // Brand Hot Magenta
                                        Color(
                                            0xFF8A2BE2), // Brand Deep Electric Violet
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE8258F)
                                            .withOpacity(0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _resetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'UPDATE PASSWORD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required bool isFocused,
    required bool obscureText,
    required VoidCallback onObscureToggle,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
          color: Color(0xFF424B5E), fontSize: 20, letterSpacing: 4),
      filled: true,
      fillColor: const Color(0xFF141925),
      prefixIcon: const Icon(Icons.lock_outline_rounded,
          color: Color(0xFF00E5FF), size: 22),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF56637F),
          size: 22,
        ),
        onPressed: onObscureToggle,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      errorStyle: const TextStyle(color: Color(0xFFFF007A)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isFocused ? const Color(0xFF00E5FF) : const Color(0xFF1E2538),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF00E5FF),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFF007A),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFF007A),
          width: 1.5,
        ),
      ),
    );
  }
}

// --- CUSTOM ARC PATH CLIPPER DESIGN SPEC FOR THE TOP BACKGROUND SURFACE PANEL ---
class ResetTopArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    Offset controlPoint = Offset(size.width / 2, size.height + 20);
    Offset endPoint = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
