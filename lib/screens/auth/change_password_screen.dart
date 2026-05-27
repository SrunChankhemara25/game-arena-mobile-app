import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/widgets.dart';

// ─── Modern & Professional Change Password Screen ────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;
  bool _loading = false;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    _currentController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _savePassword() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _loading = true);

    try {
      final email = await AuthService().getLoggedInUserEmail();
      if (email == null || email.isEmpty) {
        throw Exception('No active session found.');
      }
      await AuthService().changePassword(
        email: email,
        currentPassword: _currentController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);

      HapticFeedback.selectionClick();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.bg1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.green, size: 24),
              const SizedBox(width: 10),
              Text('Password Updated',
                  style:
                      AppText.heading.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          content: Text(
            'Your authentication credentials have been updated successfully across the network infrastructure.',
            style: AppText.body
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context); // Close Dialog
                Navigator.pop(context); // Return back to Profile Screen
              },
              child: Text(
                'OK',
                style: AppText.body.copyWith(
                    color: AppColors.cyan, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text('CHANGE PASSWORD',
            style: AppText.heading.copyWith(letterSpacing: 1.2, fontSize: 16)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Dynamic Ambient Glow Overlays matching GameArena's Identity
          Positioned(
            top: -40,
            right: -60,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withOpacity(0.05),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.magenta.withOpacity(0.04),
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
                  physics: const ClampingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update your account password to keep your profile secure.',
                          style: AppText.body.copyWith(
                              color: AppColors.textSecondary, height: 1.5),
                        ),

                        const SizedBox(height: 32),

                        // Form Glass Card Surface Container
                        Container(
                          width: double.infinity,
                          decoration: AppDecorations.glassCard(radius: 24),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AUTHENTICATION PARAMS',
                                style: AppText.label.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 24),

                              // CURRENT PASSWORD
                              _buildFieldLabel('CURRENT PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _currentController,
                                obscureText: _isCurrentObscured,
                                textInputAction: TextInputAction.next,
                                style: AppText.bodyMd
                                    .copyWith(color: AppColors.textPrimary),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your current password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter old verification token',
                                  prefixIcon: const Icon(
                                      Icons.lock_open_rounded,
                                      color: AppColors.textMuted,
                                      size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCurrentObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _isCurrentObscured =
                                            !_isCurrentObscured),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // NEW PASSWORD
                              _buildFieldLabel('NEW PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _isNewObscured,
                                textInputAction: TextInputAction.next,
                                style: AppText.bodyMd
                                    .copyWith(color: AppColors.textPrimary),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be minimum 8 characters';
                                  }
                                  if (value == _currentController.text) {
                                    return 'New password cannot match your current one';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Minimum 8 characters',
                                  prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.textMuted,
                                      size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isNewObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _isNewObscured = !_isNewObscured),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // CONFIRM NEW PASSWORD
                              _buildFieldLabel('CONFIRM NEW PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _isConfirmObscured,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _savePassword(),
                                style: AppText.bodyMd
                                    .copyWith(color: AppColors.textPrimary),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your new password';
                                  }
                                  if (value != _newPasswordController.text) {
                                    return 'Passwords configuration does not match';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Repeat new password structural pattern',
                                  prefixIcon: const Icon(
                                      Icons.gpp_good_outlined,
                                      color: AppColors.textMuted,
                                      size: 20),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textMuted,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() =>
                                        _isConfirmObscured =
                                            !_isConfirmObscured),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Execution Node Submission Block
                              SizedBox(
                                width: double.infinity,
                                child: _loading
                                    ? Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.bg2,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: AppColors.border),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: AppColors.cyan,
                                                strokeWidth: 2.5),
                                          ),
                                        ),
                                      )
                                    : GlowButton(
                                        label: 'SAVE CHANGES',
                                        width: double.infinity,
                                        height: 56,
                                        icon: Icons.save_rounded,
                                        onTap: _savePassword,
                                      ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppText.label.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }
}

// Extension implementation snippet to handle Success Feedback Haptics elegantly
extension on HapticFeedback {
  static Future<void> successOver() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }
}
