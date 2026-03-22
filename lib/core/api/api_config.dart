import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _definedBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;

    if (kIsWeb) return 'http://localhost:3000';

    // Android emulator maps host machine localhost -> 10.0.2.2
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';

    return 'http://localhost:3000';
  }
}

