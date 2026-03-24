import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home/providers/home_provider.dart';
import '../home/models/home_models.dart';
import 'order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.provider});

  final HomeProvider provider;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _service = OrderService();
  bool _loading = true;
  String? _error;
  List<HomeOrder> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getMyOrders();
      if (!mounted) return;
      setState(() {
        _orders = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        // fallback to provider orders if available
        _orders = widget.provider.orders;
        _loading = false;
      });
    }
  }

  final _fmt = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? Center(
              child: Text(_error == null ? 'Chưa có đơn hàng' : 'Lỗi: $_error'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final o = _orders[index];
                return Card(
                  child: ListTile(
                    title: Text('Đơn ${o.id}'),
                    subtitle: Text(
                      '${o.shortDate} • ${o.status} • ${o.items.length} mặt hàng',
                    ),
                    trailing: Text(_fmt.format(o.total)),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chi tiết đơn ${o.id}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            ...o.items.map(
                              (it) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(it.title),
                                    Text(
                                      '${it.quantity} x ${_fmt.format(it.price)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tổng: ${_fmt.format(o.total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Trạng thái: ${o.status}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
