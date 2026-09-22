import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'main_shell.dart';
import 'registration/registration_flow.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String mobile;
  final String email;
  final bool isEmail;

  const OtpVerificationScreen({
    super.key,
    this.mobile = '',
    this.email = '',
    this.isEmail = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  int _seconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  int get _digitsEntered => _controllers.where((c) => c.text.isNotEmpty).length;
  String get _otp => _controllers.map((c) => c.text).join();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _verify() async {
    if (_digitsEntered != 6) {
      _showError('Enter the full 6-digit OTP');
      return;
    }
    final state = context.read<AppState>();
    final result = widget.isEmail
        ? await state.verifyEmailOtp(_otp)
        : await state.verifyOtp(_otp);

    if (!mounted) return;
    if (result == 'existing') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else if (result == 'new') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistrationFlow()),
      );
    } else {
      _showError(state.errorMessage ?? 'Invalid OTP code.');
    }
  }

  void _handlePastedOrTypedText(int index, String value) {
    // If user pasted a multi-digit OTP string
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length > 1) {
      for (int k = 0; k < 6 && k < clean.length; k++) {
        _controllers[k].text = clean[k];
      }
      final targetIndex = clean.length >= 6 ? 5 : clean.length;
      _nodes[targetIndex].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty) {
      _controllers[index].text = value.substring(value.length - 1);
      if (index < 5) {
        _nodes[index + 1].requestFocus();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final display = widget.isEmail
        ? widget.email
        : (widget.mobile.isEmpty ? '98765 43210' : widget.mobile);

    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.only(top: 6, bottom: 14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(widget.isEmail ? Icons.email_outlined : Icons.mobile_friendly_rounded, color: Colors.white, size: 22),
                  ),
                  Text(widget.isEmail ? 'Verify Email OTP' : 'Verify Mobile OTP', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(widget.isEmail ? 'Sent to $display' : 'Sent to +91 $display', style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 6 Standard OTP Input Fields with Focus & Backspace Handling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 46,
                          height: 56,
                          child: Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                                if (_controllers[i].text.isEmpty && i > 0) {
                                  _controllers[i - 1].clear();
                                  _nodes[i - 1].requestFocus();
                                  setState(() {});
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _nodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.zero,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _controllers[i].text.isNotEmpty ? AppColors.navy : Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.navy, width: 2),
                                ),
                              ),
                              onChanged: (v) => _handlePastedOrTypedText(i, v),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),

                    // Requirement 4: OTP Code text completely removed!
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('$_digitsEntered/6 digits entered', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                      ],
                    ),
                    const SizedBox(height: 30),

                    const Text("Didn't receive OTP?", style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _seconds == 0 ? _startTimer : null,
                      child: Text(_seconds == 0 ? 'Resend OTP' : 'Resend OTP (${_seconds}s)',
                          style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),

                    GradientButton(
                      label: isLoading ? 'Verifying…' : 'Verify & Continue',
                      onPressed: isLoading ? null : _verify,
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
}
