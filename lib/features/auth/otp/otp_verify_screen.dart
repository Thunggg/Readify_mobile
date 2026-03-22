import 'package:flutter/material.dart';

import '../../../core/api/api_error.dart';
import '../data/auth_api.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.emailForDisplay});

  final String emailForDisplay;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();

  bool _loading = false;
  bool _resending = false;
  Map<String, dynamic>? _createdAccount;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  String? _validateOtp(String? v) {
    if (v == null || v.trim().isEmpty) return 'OTP is required';
    final value = v.trim();
    if (value.length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return 'OTP must be digits only';
    return null;
  }

  Future<void> _verify() async {
    if (_loading) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);
    try {
      final payload = await AuthApi().verifyRegisterOtp(otp: _otp.text.trim());
      if (!mounted) return;
      setState(() => _createdAccount = payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verified successfully. Account created.')),
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
    setState(() => _resending = true);
    try {
      await AuthApi().resendRegisterOtp();
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final created = _createdAccount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'We sent a 6-digit OTP to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Text(
              widget.emailForDisplay,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _otp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: '123456',
                ),
                maxLength: 6,
                validator: _validateOtp,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & create account'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _resending ? null : _resend,
              child: _resending ? const Text('Resending...') : const Text('Resend OTP'),
            ),
            if (created != null) ...[
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Created account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _kv('id', '${created['_id'] ?? created['id'] ?? ''}'),
              _kv('email', '${created['email'] ?? ''}'),
              _kv('firstName', '${created['firstName'] ?? ''}'),
              _kv('lastName', '${created['lastName'] ?? ''}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(v.isEmpty ? '-' : v)),
        ],
      ),
    );
  }
}

