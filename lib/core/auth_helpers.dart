import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/login/login_screen.dart';

/// Ensure the user is logged in. If not, open `LoginScreen` and wait for result.
/// Returns `true` when user is logged in after this call.
Future<bool> ensureLoggedIn(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  if (token != null && token.isNotEmpty) return true;

  final result = await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  return result == true;
}
