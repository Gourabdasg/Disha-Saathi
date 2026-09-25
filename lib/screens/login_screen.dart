import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'main_shell.dart';
import 'otp_verification_screen.dart';
import 'registration/registration_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _authMode = 0; // 0: Mobile OTP, 1: Email OTP

  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkRedirectResult();
    }
  }

  Future<void> _checkRedirectResult() async {
    try {
      final redirectResult = await FirebaseAuth.instance.getRedirectResult();
      if (redirectResult.user != null && mounted) {
        final user = redirectResult.user!;
        final state = context.read<AppState>();
        final result = await state.loginWithGoogle(
          user.email ?? '',
          user.displayName ?? '',
          user.uid,
        );
        if (mounted && result != null) {
          _showSuccess('Google Sign-In Successful! Welcome ${state.name.isNotEmpty ? state.name : (user.displayName ?? '')}');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        }
      }
    } catch (_) {}
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.teal),
    );
  }

  Future<void> _handleDirectGoogleSignIn() async {
    final state = context.read<AppState>();
    try {
      final userCredential = await FirebaseAuthService.signInWithGoogle();
      if (userCredential == null || userCredential.user == null) {
        return;
      }
      final user = userCredential.user!;
      final result = await state.loginWithGoogle(
        user.email ?? '',
        user.displayName ?? '',
        user.uid,
      );
      if (!mounted) return;
      if (result != null) {
        _showSuccess('Google Sign-In Successful! Welcome ${state.name.isNotEmpty ? state.name : (user.displayName ?? '')}');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        _showError(state.errorMessage ?? 'Google Sign-In failed');
      }
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      _showError(cleanMsg.isNotEmpty ? cleanMsg : 'Google Sign-In failed. Please try again.');
    }
  }

  Future<void> _submitEmailOtp() async {
    final state = context.read<AppState>();
    final email = _emailController.text.trim().toLowerCase();

    if (!email.contains('@') || email.length < 5) {
      _showError('Enter a valid email address');
      return;
    }

    final demoOtp = await state.sendEmailOtp(email);
    if (!mounted) return;
    if (demoOtp != null) {
      _showSuccess('OTP Sent to $email!');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email, isEmail: true)),
      );
    } else {
      _showError(state.errorMessage ?? 'Could not send Email OTP.');
    }
  }

  Future<void> _submitMobileOtp() async {
    final state = context.read<AppState>();
    final mobile = _mobileController.text.trim();
    if (mobile.length != 10) {
      _showError('Enter a valid 10-digit mobile number');
      return;
    }

    final otpRes = await state.sendOtp(mobile);
    if (!mounted) return;
    if (otpRes != null) {
      _showSuccess('OTP Sent to +91 $mobile!');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(mobile: mobile, isEmail: false)),
      );
    } else {
      _showError(state.errorMessage ?? 'Could not send Mobile OTP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppState>().isLoading;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 14),
                  const Text('Welcome to Disha Saathi', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Sign in with OTP or Google to continue', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Auth Mode Selector Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          _tab('Mobile OTP', _authMode == 0, () => setState(() => _authMode = 0)),
                          _tab('Email OTP', _authMode == 1, () => setState(() => _authMode = 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Google Sign-In Button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: Colors.grey.shade300),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: isLoading ? null : _handleDirectGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Sign in with Google · गूगल साइन इन',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(children: const [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or', style: TextStyle(color: AppColors.textMuted))),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 18),

                    // Form Fields
                    if (_authMode == 0) ...[
                      // Mobile OTP Mode
                      const Text('MOBILE NUMBER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(hintText: '10-digit mobile number', counterText: ''),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: isLoading ? 'Sending OTP…' : 'Send Mobile OTP',
                        onPressed: isLoading ? null : _submitMobileOtp,
                      ),
                    ] else ...[
                      // Email OTP Mode
                      const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        decoration: const InputDecoration(hintText: 'name@example.com'),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: isLoading ? 'Sending OTP…' : 'Send Email OTP',
                        onPressed: isLoading ? null : _submitEmailOtp,
                      ),
                    ],

                    const SizedBox(height: 20),
                    GradientButton(
                      label: 'Create Account · नया खाता बनाएं',
                      outlined: true,
                      onPressed: () {
                        final mobile = _mobileController.text.trim();
                        if (mobile.length == 10) {
                          context.read<AppState>().mobile = mobile;
                        }
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistrationFlow()));
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'By continuing you agree to PM-AJAY GIA Terms of Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)] : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.5, color: selected ? AppColors.navy : AppColors.textMuted)),
        ),
      ),
    );
  }
}
