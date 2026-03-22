import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_error.dart';
import '../data/auth_api.dart';
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
          builder: (_) => OtpVerifyScreen(emailForDisplay: _email.text.trim().toLowerCase()),
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
    final dobText = _dateOfBirth == null ? 'Select date of birth' : DateFormat('yyyy-MM-dd').format(_dateOfBirth!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _firstName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (v) => _required(v, 'First name is required'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (v) => _required(v, 'Last name is required'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => _required(v, 'Address is required'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _loading ? null : _pickDob,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(dobText)),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Unknown')),
                  DropdownMenuItem(value: 1, child: Text('Male')),
                  DropdownMenuItem(value: 2, child: Text('Female')),
                ],
                onChanged: _loading ? null : (v) => setState(() => _sex = v ?? 0),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) {
                  final msg = _required(v, 'Password is required');
                  if (msg != null) return msg;
                  if ((v ?? '').length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPassword,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                validator: (v) {
                  final msg = _required(v, 'Confirm password is required');
                  if (msg != null) return msg;
                  if ((v ?? '').length < 8) return 'Confirm password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

