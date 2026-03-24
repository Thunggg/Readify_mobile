import 'package:flutter/material.dart';

import '../../../core/api/api_error.dart';
import '../data/profile_api.dart';

class ProfilePasswordScreen extends StatefulWidget {
  const ProfilePasswordScreen({super.key});

  @override
  State<ProfilePasswordScreen> createState() => _ProfilePasswordScreenState();
}

class _ProfilePasswordScreenState extends State<ProfilePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileApi _api = ProfileApi();

  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();

  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v, String message) {
    if (v == null) return message;
    if (v.trim().isEmpty) return message;
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_newPass.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirm password do not match')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _api.changePassword(
        currentPassword: _current.text,
        newPassword: _newPass.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F04A);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Change password'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              _pillPassword(
                controller: _current,
                hintText: 'Current password',
                enabled: !_saving,
                obscure: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) {
                  final msg = _required(v, 'Current password is required');
                  if (msg != null) return msg;
                  if ((v ?? '').length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _pillPassword(
                controller: _newPass,
                hintText: 'New password',
                enabled: !_saving,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) {
                  final msg = _required(v, 'New password is required');
                  if (msg != null) return msg;
                  if ((v ?? '').length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _pillPassword(
                controller: _confirm,
                hintText: 'Confirm password',
                enabled: !_saving,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  final msg = _required(v, 'Confirm password is required');
                  if (msg != null) return msg;
                  if ((v ?? '').length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
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
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillPassword({
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    const accent = Color(0xFFB7F04A);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.90)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.55)),
        suffixIcon: InkWell(
          onTap: enabled ? onToggle : null,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white.withValues(alpha: 0.55),
          ),
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

