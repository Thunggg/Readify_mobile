import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_error.dart';
import '../data/auth_api.dart';
import '../login/login_screen.dart';
import '../otp/otp_verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  DateTime? _dateOfBirth;
  int _sex = 0;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showMore = true;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _required(String? v, String message) {
    if (v == null) return message;
    if (v.trim().isEmpty) return message;
    return null;
  }

  String? _validateEmail(String? v) {
    final msg = _required(v, 'Email is required');
    if (msg != null) return msg;
    final value = v!.trim();
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'Invalid email';
  }

  String? _validatePhone(String? v) {
    final msg = _required(v, 'Phone is required');
    if (msg != null) return msg;
    final value = v!.trim();
    final ok = RegExp(r'^[0-9]+$').hasMatch(value);
    return ok ? null : 'Phone must be digits only';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (_loading) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    final password = _password.text;
    final confirm = _confirmPassword.text;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password and confirm password do not match')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final dobIso = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);
      await AuthApi().register(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        dateOfBirthIso: dobIso,
        sex: _sex,
        email: _email.text.trim().toLowerCase(),
        password: password,
        confirmPassword: confirm,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            emailForDisplay: _email.text.trim().toLowerCase(),
            otpLength: 6,
            topTitle: 'Verify Email',
            instruction: 'You need to enter ${6}-digit code we sent to your email.',
            confirmLabel: 'Confirm',
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = const Color(0xFFB7F04A);
    final dobText = _dateOfBirth == null ? 'Date of birth' : DateFormat('yyyy-MM-dd').format(_dateOfBirth!);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0B0B0B),
                      scheme.surface.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                        children: const [
                          TextSpan(text: 'Shop'),
                          TextSpan(text: '.', style: TextStyle(color: Color(0xFFB7F04A))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                        const SizedBox(height: 4),
                        Text(
                          'Get Started',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your details below',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                        ),
                        const SizedBox(height: 18),

                        // Keep all required fields, but group them nicely.
                        Row(
                          children: [
                            Expanded(
                              child: _PillTextField(
                                controller: _firstName,
                                hintText: 'First name',
                                prefixIcon: Icons.person_outline,
                                enabled: !_loading,
                                validator: (v) => _required(v, 'First name is required'),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PillTextField(
                                controller: _lastName,
                                hintText: 'Last name',
                                prefixIcon: Icons.person_outline,
                                enabled: !_loading,
                                validator: (v) => _required(v, 'Last name is required'),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PillTextField(
                          controller: _phone,
                          hintText: 'Mobile Number',
                          prefixIcon: Icons.phone_outlined,
                          enabled: !_loading,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _PillTextField(
                          controller: _email,
                          hintText: 'Email',
                          prefixIcon: Icons.mail_outline,
                          enabled: !_loading,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _PillTextField(
                          controller: _password,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          enabled: !_loading,
                          obscureText: _obscurePassword,
                          suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) {
                            final msg = _required(v, 'Password is required');
                            if (msg != null) return msg;
                            if ((v ?? '').length < 8) return 'Password must be at least 8 characters';
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _PillTextField(
                          controller: _confirmPassword,
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          enabled: !_loading,
                          obscureText: _obscureConfirm,
                          suffixIcon: _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (v) {
                            final msg = _required(v, 'Confirm password is required');
                            if (msg != null) return msg;
                            if ((v ?? '').length < 8) return 'Confirm password must be at least 8 characters';
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _loading ? null : () => setState(() => _showMore = !_showMore),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'More details (required)',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.70),
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _showMore ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showMore) ...[
                          const SizedBox(height: 2),
                          _PillTextField(
                            controller: _address,
                            hintText: 'Address',
                            prefixIcon: Icons.location_on_outlined,
                            enabled: !_loading,
                            validator: (v) => _required(v, 'Address is required'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _loading ? null : _pickDob,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: Colors.white.withValues(alpha: 0.55), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      dobText,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: _dateOfBirth == null
                                                ? Colors.white.withValues(alpha: 0.45)
                                                : Colors.white.withValues(alpha: 0.90),
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.45)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _sex,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: BorderSide(color: accent.withValues(alpha: 0.75)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Sex: Unknown')),
                              DropdownMenuItem(value: 1, child: Text('Sex: Male')),
                              DropdownMenuItem(value: 2, child: Text('Sex: Female')),
                            ],
                            onChanged: _loading ? null : (v) => setState(() => _sex = v ?? 0),
                          ),
                        ],

                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                            const SizedBox(width: 10),
                            Text(
                              'Or continue with',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: 'Google',
                                icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w900)),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Google sign-in not implemented')),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SocialButton(
                                label: 'Apple',
                                icon: const Icon(Icons.apple, size: 20),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Apple sign-in not implemented')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
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

class _PillTextField extends StatelessWidget {
  const _PillTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.enabled,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFB7F04A);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.90)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.55)),
        suffixIcon: suffixIcon == null
            ? null
            : InkWell(
                onTap: enabled ? onSuffixTap : null,
                child: Icon(suffixIcon, color: Colors.white.withValues(alpha: 0.55)),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.75)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: Colors.white.withValues(alpha: 0.85)),
              child: icon,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

