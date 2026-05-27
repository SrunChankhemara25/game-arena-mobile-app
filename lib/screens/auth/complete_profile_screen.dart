import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/auth_service.dart'; // ─── CONNECTED BACKEND ENGINE ───
import '../main_nav.dart'; // Ensure this points to your real main navigation screen

class CompleteProfileScreen extends StatefulWidget {
  final String email;

  const CompleteProfileScreen({super.key, required this.email});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCountry;

  bool _loading = false;

  final List<String> _countries = [
    'Cambodia',
    'Vietnam',
    'Philippines',
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Myanmar'
  ];

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ─── YOUR SIGNATURE SMOOTH LOAD ANIMATION ───
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
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
    _nameController.dispose();
    super.dispose();
  }

  // ─── FINAL GOOGLE SETUP LOGIC ───
  void _completeSetup() async {
    if (!_formKey.currentState!.validate() || _selectedCountry == null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _loading = true);

    try {
      // Create the final user document in Firestore.
      // Password is left empty because they authenticated securely via Google.
      await AuthService().registerUser(
        email: widget.email,
        name: _nameController.text.trim(),
        country: _selectedCountry!,
        password: '',
      );
      await AuthService().saveUserSession(widget.email);

      if (!mounted) return;
      HapticFeedback.successNotification();

      // Enter the main app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNav()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Header Text
                    const Text(
                      'Almost there!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let us know what to call you and where you are playing from.',
                      style: TextStyle(
                          color: Color(0xFF7A8498), fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 48),

                    // Display Name Field
                    _buildLabel('Display Name'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          hint: 'Enter your name', icon: Icons.person_outline),
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Country Dropdown
                    _buildLabel('Country'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      dropdownColor: const Color(0xFF1A1F2C),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          hint: 'Select your country', icon: Icons.public),
                      items: _countries.map((String country) {
                        return DropdownMenuItem(
                            value: country, child: Text(country));
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 48),

                    // Main Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _completeSetup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text(
                                'COMPLETE SETUP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
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
    );
  }

  // ─── UI HELPER: MATCHES YOUR EXACT LABEL STYLE ───
  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF7A8498),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFFF453A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── UI HELPER: MATCHES YOUR EXACT INPUT FIELD STYLE ───
  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
      filled: true,
      fillColor: const Color(0xFF1A1F2C),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3344)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C3344)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5),
      ),
    );
  }
}
