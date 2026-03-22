import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api/api_error.dart';
import '../data/auth_api.dart';
import '../login/login_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.emailForDisplay,
    this.otpLength = 6,
    this.cooldownSeconds = 60,
    this.topTitle = 'Forget Password',
    this.cardTitle = 'Verification Code',
    this.instruction = 'You need to enter code we sent to your email.',
    this.confirmLabel = 'Confirm',
  });

  final String emailForDisplay;
  final int otpLength;
  final int cooldownSeconds;
  final String topTitle;
  final String cardTitle;
  final String instruction;
  final String confirmLabel;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  bool _loading = false;
  bool _resending = false;

  late final List<String> _digits;
  Timer? _timer;
  late int _cooldownLeft;

  @override
  void initState() {
    super.initState();
    _digits = List<String>.filled(widget.otpLength, '');
    _cooldownLeft = widget.cooldownSeconds;
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _otpValue => _digits.join();
  bool get _isOtpComplete => !_digits.contains('');

  void _startCooldown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _cooldownLeft = (_cooldownLeft - 1).clamp(0, widget.cooldownSeconds);
      });
      if (_cooldownLeft <= 0) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  void _resetCooldown() {
    setState(() => _cooldownLeft = widget.cooldownSeconds);
    _startCooldown();
  }

  void _onKeyTap(String key) {
    if (_loading) return;

    if (key == 'back') {
      for (var i = widget.otpLength - 1; i >= 0; i--) {
        if (_digits[i].isNotEmpty) {
          setState(() => _digits[i] = '');
          return;
        }
      }
      return;
    }

    if (!RegExp(r'^[0-9]$').hasMatch(key)) return;
    for (var i = 0; i < widget.otpLength; i++) {
      if (_digits[i].isEmpty) {
        setState(() => _digits[i] = key);
        return;
      }
    }
  }

  Future<void> _verify() async {
    if (_loading) return;
    if (!_isOtpComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter ${widget.otpLength}-digit code')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApi().verifyRegisterOtp(otp: _otpValue);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prettyDioError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    if (_cooldownLeft > 0) return;
    setState(() => _resending = true);
    try {
      await AuthApi().resendRegisterOtp();
      if (!mounted) return;
      _resetCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent. Please check your email.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prettyDioError(e))),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String _formatCooldown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString()}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F04A);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  Text(
                    widget.topTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          widget.cardTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.instruction,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.emailForDisplay,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 18),
                        _OtpBoxesRow(
                          otpLength: widget.otpLength,
                          digits: _digits,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _loading ? null : _verify,
                            child: _loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    widget.confirmLabel,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: GestureDetector(
                            onTap: (_resending || _cooldownLeft > 0) ? null : _resend,
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.55),
                                    ),
                                children: [
                                  const TextSpan(text: "Didn't get the code yet ?  "),
                                  TextSpan(
                                    text: _cooldownLeft > 0 ? 'Resend(${_formatCooldown(_cooldownLeft)})' : 'Resend',
                                    style: TextStyle(
                                      color: _cooldownLeft > 0 ? Colors.white.withValues(alpha: 0.60) : accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            _Keypad(
              onKeyTap: _onKeyTap,
              onBackspace: () => _onKeyTap('back'),
              disabled: _loading,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.85)),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.value});

  final String value;
  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _OtpBoxesRow extends StatelessWidget {
  const _OtpBoxesRow({required this.otpLength, required this.digits});

  final int otpLength;
  final List<String> digits;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        const minBoxWidth = 44.0;
        final available = constraints.maxWidth;
        final totalGaps = gap * (otpLength - 1);
        final boxWidth = ((available - totalGaps) / otpLength).floorToDouble();

        // If OTP length is large, keep single row with horizontal scroll.
        final needsScroll = boxWidth < minBoxWidth;
        final width = needsScroll ? minBoxWidth : boxWidth;

        final row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(otpLength, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i == otpLength - 1 ? 0 : gap),
              child: SizedBox(
                width: width,
                child: _OtpBox(value: digits[i]),
              ),
            );
          }),
        );

        if (!needsScroll) return row;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: row,
        );
      },
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onKeyTap,
    required this.onBackspace,
    required this.disabled,
  });

  final void Function(String key) onKeyTap;
  final VoidCallback onBackspace;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(['1', '2', '3']),
          const SizedBox(height: 14),
          _row(['4', '5', '6']),
          const SizedBox(height: 14),
          _row(['7', '8', '9']),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _KeypadButton(
                  label: '*',
                  onTap: null,
                  disabled: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KeypadButton(
                  label: '0',
                  onTap: disabled ? null : () => onKeyTap('0'),
                  disabled: disabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KeypadButton(
                  icon: Icons.backspace_outlined,
                  onTap: disabled ? null : onBackspace,
                  disabled: disabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          Expanded(
            child: _KeypadButton(
              label: keys[i],
              onTap: disabled ? null : () => onKeyTap(keys[i]),
              disabled: disabled,
            ),
          ),
          if (i != keys.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    required this.disabled,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 56,
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white.withValues(alpha: 0.85))
              : Text(
                  label ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                ),
        ),
      ),
    );
  }
}

