import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_error.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/login/login_screen.dart';
import '../data/profile_api.dart';
import 'profile_edit_screen.dart';
import 'profile_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileApi _api = ProfileApi();
  Map<String, dynamic>? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await _api.getMe();
      if (!mounted) return;
      setState(() => _me = me);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prettyDioError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fullName(Map<String, dynamic> me) {
    final first = (me['firstName'] ?? '').toString().trim();
    final last = (me['lastName'] ?? '').toString().trim();
    final name = ('$first $last').trim();
    return name.isEmpty ? 'User' : name;
  }

  String _sexText(dynamic raw) {
    final v = int.tryParse(raw?.toString() ?? '') ?? 0;
    return switch (v) { 1 => 'Male', 2 => 'Female', _ => 'Unknown' };
  }

  String _dobText(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '-';
    try {
      final d = DateTime.parse(s);
      return DateFormat('yyyy-MM-dd').format(d);
    } catch (_) {
      return s;
    }
  }

  Future<void> _openEdit() async {
    final me = _me;
    if (me == null) return;
    final updated = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => ProfileEditScreen(initial: me)),
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() => _me = updated);
    } else {
      // In case edit did partial update, re-fetch for consistency
      await _load();
    }
  }

  Future<void> _openChangePassword() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePasswordScreen()),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthApi().logout();
    } catch (_) {
      // Ignore network errors; still navigate to login
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F04A);
    final me = _me;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : me == null
                ? Center(
                    child: FilledButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            children: [
                              _Avatar(url: (me['avatarUrl'] ?? '').toString()),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fullName(me),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (me['email'] ?? '').toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: _openEdit,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoCard(
                          title: 'Personal info',
                          rows: [
                            _InfoRow('Phone', (me['phone'] ?? '-').toString()),
                            _InfoRow('Address', (me['address'] ?? '-').toString()),
                            _InfoRow('Date of birth', _dobText(me['dateOfBirth'])),
                            _InfoRow('Sex', _sexText(me['sex'])),
                            _InfoRow('Bio', (me['bio'] ?? '-').toString()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _openEdit,
                            child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                            ),
                            onPressed: _openChangePassword,
                            child: const Text('Change password'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                            ),
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      backgroundImage: hasUrl ? NetworkImage(url) : null,
      child: hasUrl ? null : const Icon(Icons.person, size: 28),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final r in rows) ...[
            _InfoRowWidget(row: r),
            if (r != rows.last) Divider(color: Colors.white.withValues(alpha: 0.08), height: 14),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
}

class _InfoRowWidget extends StatelessWidget {
  const _InfoRowWidget({required this.row});
  final _InfoRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            row.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.60)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            row.value.isEmpty ? '-' : row.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.90)),
          ),
        ),
      ],
    );
  }
}

