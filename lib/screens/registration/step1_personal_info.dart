import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class Step1PersonalInfo extends StatefulWidget {
  const Step1PersonalInfo({super.key});

  @override
  State<Step1PersonalInfo> createState() => _Step1PersonalInfoState();
}

class _Step1PersonalInfoState extends State<Step1PersonalInfo> {
  late final TextEditingController _mobile;
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _scCategoryNo = TextEditingController();
  String _category = 'Scheduled Caste (SC)';
  bool _emailVerified = false;
  bool _isSendingOtp = false;

  static const _categories = ['Scheduled Caste (SC)', 'Scheduled Tribe (ST)', 'OBC', 'General'];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _mobile = TextEditingController(text: appState.mobile);
    _name = TextEditingController(text: appState.name);
    _email = TextEditingController(text: appState.email);
    if (appState.email.isNotEmpty && appState.isAuthenticated) {
      _emailVerified = true;
    }
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

  Future<void> _verifyEmailInline() async {
    final email = _email.text.trim();
    if (!email.contains('@') || email.length < 5) {
      _showError('Enter a valid email address');
      return;
    }

    setState(() => _isSendingOtp = true);
    final state = context.read<AppState>();
    final demoOtp = await state.sendEmailOtp(email);
    setState(() => _isSendingOtp = false);

    if (!mounted) return;
    if (demoOtp != null) {
      _showSuccess('OTP Sent to $email!');
      _showEmailOtpDialog(email, demoOtp);
    } else {
      _showError(state.errorMessage ?? 'Could not send OTP to $email');
    }
  }

  void _showEmailOtpDialog(String email, String demoOtp) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.mark_email_read_rounded, color: AppColors.teal),
              SizedBox(width: 8),
              Text('Verify Email OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the 6-digit OTP code sent to:', style: const TextStyle(fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 6),
                decoration: const InputDecoration(
                  hintText: '123456',
                  counterText: '',
                  hintStyle: TextStyle(letterSpacing: 6, color: Colors.black26),
                ),
              ),
              const SizedBox(height: 10),
              Text('Demo Code: $demoOtp', style: const TextStyle(fontSize: 11.5, color: AppColors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isVerifying
                  ? null
                  : () async {
                      final enteredOtp = otpController.text.trim();
                      if (enteredOtp.length != 6) {
                        _showError('Enter the full 6-digit OTP code');
                        return;
                      }
                      setDialogState(() => isVerifying = true);
                      final state = context.read<AppState>();
                      final result = await state.verifyEmailOtp(enteredOtp);
                      setDialogState(() => isVerifying = false);

                      if (result != null) {
                        Navigator.pop(ctx);
                        setState(() => _emailVerified = true);
                        _showSuccess('Email address verified successfully!');
                      } else {
                        _showError('Invalid OTP code. Please try again.');
                      }
                    },
              child: Text(isVerifying ? 'Verifying…' : 'Verify & Confirm', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('YOUR NAME'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Full name'),
          ),
          const SizedBox(height: 18),

          // Email Address Input with Inline Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('EMAIL ADDRESS'),
              if (_emailVerified)
                Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_emailVerified) {
                setState(() => _emailVerified = false);
              }
            },
            decoration: InputDecoration(
              hintText: 'name@example.com',
              suffixIcon: _emailVerified
                  ? const Icon(Icons.verified_rounded, color: Colors.green, size: 22)
                  : TextButton(
                      onPressed: _isSendingOtp ? null : _verifyEmailInline,
                      child: Text(
                        _isSendingOtp ? 'Sending…' : 'Verify Email',
                        style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          _label('MOBILE NUMBER'),
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
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(hintText: '10-digit mobile number', counterText: ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _label('CATEGORY'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
            ),
          ),
          const SizedBox(height: 18),

          _label('SC CATEGORY NO. / CERTIFICATE NO.'),
          TextField(
            controller: _scCategoryNo,
            decoration: const InputDecoration(hintText: 'SC Category / Certificate No.'),
          ),
          const SizedBox(height: 36),

          GradientButton(
            label: 'Continue',
            onPressed: () {
              final name = _name.text.trim();
              final mobile = _mobile.text.trim();
              final email = _email.text.trim();
              if (name.isEmpty) {
                _showError('Enter your name');
                return;
              }
              if (mobile.length != 10) {
                _showError('Enter a valid 10-digit mobile number');
                return;
              }
              if (email.isNotEmpty && !_emailVerified) {
                _showError('Please verify your email address before continuing');
                _verifyEmailInline();
                return;
              }
              final state = context.read<AppState>();
              state.name = name;
              state.email = email;
              state.mobile = mobile;
              state.category = _category;
              state.scCategoryNo = _scCategoryNo.text.trim();
              state.nextRegistrationStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4)),
  );
}
