import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  late final TextEditingController _district;
  late final TextEditingController _state;
  final _scCategoryNo = TextEditingController();

  String _category = 'Scheduled Caste (SC)';
  bool _emailVerified = false;
  bool _isSendingOtp = false;

  int _locationMode = 0; // 0: Auto Current Location, 1: Enter Manually
  bool _isDetectingLocation = false;
  String _detectedLocation = 'Barasat, West Bengal';

  static const _categories = ['Scheduled Caste (SC)', 'Scheduled Tribe (ST)', 'OBC', 'General'];

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _mobile = TextEditingController(text: appState.mobile);
    _name = TextEditingController(text: appState.name);
    _email = TextEditingController(text: appState.email);
    _district = TextEditingController(text: appState.district.isNotEmpty ? appState.district : 'Barasat');
    _state = TextEditingController(text: appState.stateName.isNotEmpty ? appState.stateName : 'West Bengal');

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

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final city = data['city'] as String? ?? 'Barasat';
        final region = data['regionName'] as String? ?? 'West Bengal';
        setState(() {
          _detectedLocation = '$city, $region';
          _district.text = city;
          _state.text = region;
          _isDetectingLocation = false;
        });
        _showSuccess('Current Location Detected: $_detectedLocation');
        return;
      }
    } catch (_) {
      // Permission denied or network fallback
    }

    setState(() {
      _isDetectingLocation = false;
      _detectedLocation = 'Barasat, West Bengal';
      _district.text = 'Barasat';
      _state.text = 'West Bengal';
    });
    _showError('Location permission/service unavailable. Using default: Barasat, West Bengal. You can enter manually below.');
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
                        if (ctx.mounted) Navigator.pop(ctx);
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

          // Requirement 1: Location Section (Current Location vs Manual Input)
          _label('YOUR LOCATION'),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _locationMode = 0);
                      _detectCurrentLocation();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _locationMode == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _locationMode == 0 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.my_location_rounded, size: 16, color: AppColors.teal),
                          SizedBox(width: 6),
                          Text('Use Current Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _locationMode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _locationMode == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _locationMode == 1 ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.navy),
                          SizedBox(width: 6),
                          Text('Enter Manually', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.navy)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (_locationMode == 0) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.teal.withOpacity(0.2))),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.teal, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isDetectingLocation ? 'Detecting current location…' : 'Selected: $_detectedLocation',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 13),
                    ),
                  ),
                  if (_isDetectingLocation)
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal)),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _district,
                    decoration: const InputDecoration(hintText: 'City / District (e.g. Barasat)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _state,
                    decoration: const InputDecoration(hintText: 'State (e.g. West Bengal)'),
                  ),
                ),
              ],
            ),
          ],
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
              final districtVal = _district.text.trim().isNotEmpty ? _district.text.trim() : 'Barasat';
              final stateVal = _state.text.trim().isNotEmpty ? _state.text.trim() : 'West Bengal';

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
              state.district = districtVal;
              state.stateName = stateVal;
              state.location = '$districtVal, $stateVal';
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
