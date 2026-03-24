import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_error.dart';
import '../data/media_api.dart';
import '../data/profile_api.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.initial});

  final Map<String, dynamic> initial;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileApi _api = ProfileApi();
  final MediaApi _mediaApi = MediaApi();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _avatarUrl;
  late final TextEditingController _bio;

  DateTime? _dob;
  int _sex = 0;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final me = widget.initial;
    _firstName = TextEditingController(text: (me['firstName'] ?? '').toString());
    _lastName = TextEditingController(text: (me['lastName'] ?? '').toString());
    _phone = TextEditingController(text: (me['phone'] ?? '').toString());
    _address = TextEditingController(text: (me['address'] ?? '').toString());
    _avatarUrl = TextEditingController(text: (me['avatarUrl'] ?? '').toString());
    _bio = TextEditingController(text: (me['bio'] ?? '').toString());
    _sex = int.tryParse((me['sex'] ?? 0).toString()) ?? 0;
    final dobRaw = (me['dateOfBirth'] ?? '').toString();
    if (dobRaw.isNotEmpty) {
      try {
        _dob = DateTime.parse(dobRaw);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _address.dispose();
    _avatarUrl.dispose();
    _bio.dispose();
    super.dispose();
  }

  String? _required(String? v, String message) {
    if (v == null) return message;
    if (v.trim().isEmpty) return message;
    return null;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _dob = picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date of birth')));
      return;
    }

    setState(() => _saving = true);
    try {
      final patch = <String, dynamic>{
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'avatarUrl': _avatarUrl.text.trim(),
        'bio': _bio.text.trim(),
        'sex': _sex,
        // Backend expects date string format, safest to send yyyy-MM-dd
        'dateOfBirth': DateFormat('yyyy-MM-dd').format(_dob!),
      };

      final updated = await _api.updateMe(patch);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_saving || _uploadingAvatar) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploadingAvatar = true);
      final url = await _mediaApi.uploadAvatar(picked);
      if (!mounted) return;
      setState(() => _avatarUrl.text = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar uploaded')),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = prettyDioError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F04A);
    final dobText = _dob == null ? 'Date of birth' : DateFormat('yyyy-MM-dd').format(_dob!);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Edit profile'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              _pillField(
                controller: _firstName,
                hintText: 'First name',
                prefixIcon: Icons.person_outline,
                enabled: !_saving,
                validator: (v) => _required(v, 'First name is required'),
              ),
              const SizedBox(height: 12),
              _pillField(
                controller: _lastName,
                hintText: 'Last name',
                prefixIcon: Icons.person_outline,
                enabled: !_saving,
                validator: (v) => _required(v, 'Last name is required'),
              ),
              const SizedBox(height: 12),
              _pillField(
                controller: _phone,
                hintText: 'Phone',
                prefixIcon: Icons.phone_outlined,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _pillField(
                controller: _address,
                hintText: 'Address',
                prefixIcon: Icons.location_on_outlined,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _saving ? null : _pickDob,
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
                                color: _dob == null ? Colors.white.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.90),
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
                onChanged: _saving ? null : (v) => setState(() => _sex = v ?? 0),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      backgroundImage: _avatarUrl.text.trim().isNotEmpty ? NetworkImage(_avatarUrl.text.trim()) : null,
                      child: _avatarUrl.text.trim().isNotEmpty ? null : const Icon(Icons.person, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avatar',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _avatarUrl.text.trim().isEmpty ? 'No avatar uploaded' : 'Uploaded',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.60)),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: (_saving || _uploadingAvatar) ? null : _pickAndUploadAvatar,
                      child: _uploadingAvatar
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Choose', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _pillField(
                controller: _avatarUrl,
                hintText: 'Avatar URL (optional)',
                prefixIcon: Icons.link,
                enabled: !_saving,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bio,
                enabled: !_saving,
                minLines: 3,
                maxLines: 6,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.90)),
                decoration: InputDecoration(
                  hintText: 'Bio',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: accent.withValues(alpha: 0.75)),
                  ),
                ),
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

  Widget _pillField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    const accent = Color(0xFFB7F04A);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.90)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        prefixIcon: Icon(prefixIcon, color: Colors.white.withValues(alpha: 0.55)),
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

