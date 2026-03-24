import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';

class MediaApi {
  MediaApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  /// Upload image to backend `/media/upload` (Cloudinary) and return hosted URL.
  Future<String> uploadAvatar(XFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
        'type': 'image',
        'folder': 'account',
      });

      final res = await _dio.post(
        '/media/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = res.data;
      if (data is Map && data['success'] == true) {
        final payload = data['data'];
        if (payload is Map) {
          final url = payload['url']?.toString() ?? '';
          if (url.trim().isNotEmpty) return url;
        }
        throw ApiError('Upload succeeded but missing url', statusCode: res.statusCode);
      }
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Upload failed', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}

