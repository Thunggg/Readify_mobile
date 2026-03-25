import 'package:dio/dio.dart';

import '../home/models/home_models.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';

class OrderService {
  OrderService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<HomeOrder>> getMyOrders() async {
    try {
      final res = await _dio.get('/orders');
      final payload = res.data;

      // Expect payload structure: { success: true, data: [...] } or raw list
      dynamic data;
      if (payload is Map && payload['success'] == true) {
        data = payload['data'];
      } else if (payload is List) {
        data = payload;
      } else if (payload is Map && payload['data'] is List) {
        data = payload['data'];
      } else {
        throw ApiError('Get orders failed');
      }

      if (data is! List) return const [];

      return data
          .whereType<Map>()
          .map((m) {
            final id = (m['_id'] ?? m['id'] ?? '').toString();
            final createdAt =
                DateTime.tryParse(
                  (m['createdAt'] ?? m['created_at'] ?? '').toString(),
                ) ??
                DateTime.now();
            final total =
                int.tryParse((m['total'] ?? m['amount'] ?? '0').toString()) ??
                0;
            final status = (m['status'] ?? 'Unknown').toString();

            List<HomeOrderItem> items = const [];
            final itemsRaw = m['items'] ?? m['orderItems'] ?? m['lines'];
            if (itemsRaw is List) {
              items = itemsRaw
                  .whereType<Map>()
                  .map((it) {
                    final title = (it['title'] ?? it['name'] ?? '').toString();
                    final qty =
                        int.tryParse(
                          (it['quantity'] ?? it['qty'] ?? '1').toString(),
                        ) ??
                        1;
                    final price =
                        int.tryParse(
                          (it['price'] ?? it['amount'] ?? '0').toString(),
                        ) ??
                        0;
                    return HomeOrderItem(
                      title: title,
                      quantity: qty,
                      price: price,
                    );
                  })
                  .toList(growable: false);
            }

            return HomeOrder(
              id: id,
              createdAt: createdAt,
              total: total,
              status: status,
              items: items,
            );
          })
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiError(
        e.message ?? 'Get orders failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<HomeOrder> createOrder({
    required List<Map<String, dynamic>> items,
    required int total,
    String paymentMethod = 'cod',
    String? voucherCode,
  }) async {
    try {
      final payload = {
        'items': items,
        'total': total,
        'paymentMethod': paymentMethod,
        if (voucherCode != null) 'voucher': voucherCode,
      };

      final res = await _dio.post('/orders', data: payload);
      final body = res.data;

      // Attempt to parse returned order, fall back to constructing from payload
      Map? m;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        m = body['data'] as Map;
      } else if (body is Map && body['_id'] != null) {
        m = body as Map;
      }

      if (m != null) {
        final id = (m['_id'] ?? m['id'] ?? '').toString();
        final createdAt =
            DateTime.tryParse(
              (m['createdAt'] ?? m['created_at'] ?? DateTime.now().toString())
                  .toString(),
            ) ??
            DateTime.now();
        final totalResp =
            int.tryParse((m['total'] ?? m['amount'] ?? total).toString()) ??
            total;
        final status = (m['status'] ?? 'Pending').toString();

        List<HomeOrderItem> parsedItems = [];
        final itemsRaw = m['items'] ?? m['orderItems'] ?? items;
        if (itemsRaw is List) {
          parsedItems = itemsRaw
              .whereType<Map>()
              .map(
                (it) => HomeOrderItem(
                  title: (it['title'] ?? it['name'] ?? '').toString(),
                  quantity:
                      int.tryParse(
                        (it['quantity'] ?? it['qty'] ?? '1').toString(),
                      ) ??
                      1,
                  price:
                      int.tryParse(
                        (it['price'] ?? it['amount'] ?? '0').toString(),
                      ) ??
                      0,
                ),
              )
              .toList(growable: false);
        }

        return HomeOrder(
          id: id.isNotEmpty
              ? id
              : 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
          createdAt: createdAt,
          total: totalResp,
          status: status,
          items: parsedItems,
        );
      }

      // Fallback: construct order locally
      final fallbackItems = items
          .map(
            (it) => HomeOrderItem(
              title: it['title']?.toString() ?? '',
              quantity: (it['quantity'] is int)
                  ? it['quantity'] as int
                  : int.tryParse((it['quantity'] ?? '1').toString()) ?? 1,
              price:
                  int.tryParse(
                    (it['price'] ?? it['amount'] ?? '0').toString(),
                  ) ??
                  0,
            ),
          )
          .toList(growable: false);

      return HomeOrder(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
        createdAt: DateTime.now(),
        total: total,
        status: 'Pending',
        items: fallbackItems,
      );
    } on DioException catch (e) {
      // On error, still create a local order representation so UI can show details
      final fallbackItems = items
          .map(
            (it) => HomeOrderItem(
              title: it['title']?.toString() ?? '',
              quantity: (it['quantity'] is int)
                  ? it['quantity'] as int
                  : int.tryParse((it['quantity'] ?? '1').toString()) ?? 1,
              price:
                  int.tryParse(
                    (it['price'] ?? it['amount'] ?? '0').toString(),
                  ) ??
                  0,
            ),
          )
          .toList(growable: false);

      return HomeOrder(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
        createdAt: DateTime.now(),
        total: total,
        status: 'Pending',
        items: fallbackItems,
      );
    }
  }
}
