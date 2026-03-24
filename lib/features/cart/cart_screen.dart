import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cart_service.dart';
import 'cart_models.dart';
import '../order/order_service.dart';
import '../order/order_screen.dart';
import '../order/order_repository.dart';
import '../home/providers/home_provider.dart';
import '../home/models/home_models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// Simple voucher model for cart UI
class _Voucher {
  final String code;
  final String label;
  final int? percent;
  final int? amount;

  const _Voucher({
    required this.code,
    required this.label,
    this.percent,
    this.amount,
  });
}

enum PaymentMethod { cod, vnpay }

class _CartScreenState extends State<CartScreen> {
  final CartService _service = CartService.instance;
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );
  // Mock vouchers for cart
  final List<_Voucher> _vouchers = const [
    _Voucher(code: 'NEWUSER10', label: 'Giảm 10%', percent: 10),
    _Voucher(code: 'SPRING50', label: 'Giảm 50.000đ', amount: 50000),
  ];
  _Voucher? _selectedVoucher;

  PaymentMethod _paymentMethod = PaymentMethod.cod;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChange);
  }

  @override
  void dispose() {
    _service.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  Future<void> _checkout() async {
    if (_service.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống')));
      return;
    }

    final total = _calculateTotal();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: Text(
          'Tổng sau giảm: ${_currency.format(total)}\nPhương thức: ${_paymentMethod == PaymentMethod.cod ? 'COD' : 'VNPAY (sandbox)'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thanh toán'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_paymentMethod == PaymentMethod.vnpay) {
        // Simulate VNPAY sandbox flow
        final vnpay = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('VNPAY Sandbox'),
            content: Text(
              'Mô phỏng chuyển đến VNPAY sandbox để thanh toán ${_currency.format(total)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thanh toán (sandbox)'),
              ),
            ],
          ),
        );

        if (vnpay != true) return;
      }

      // Create order (try server, fallback to local) and show order details
      final orderService = OrderService();
      final itemsPayload = _service.items
          .map(
            (it) => {
              'title': it.book.title,
              'quantity': it.quantity,
              'price': it.book.basePrice.toInt(),
            },
          )
          .toList(growable: false);

      HomeOrder createdOrder;
      try {
        createdOrder = await orderService.createOrder(
          items: itemsPayload,
          total: total,
          paymentMethod: _paymentMethod == PaymentMethod.cod ? 'cod' : 'vnpay',
          voucherCode: _selectedVoucher?.code,
        );
      } catch (_) {
        // createOrder already falls back, but guard anyway
        createdOrder = HomeOrder(
          id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
          createdAt: DateTime.now(),
          total: total,
          status: 'Pending',
          items: _service.items
              .map(
                (it) => HomeOrderItem(
                  title: it.book.title,
                  quantity: it.quantity,
                  price: it.book.basePrice.toInt(),
                ),
              )
              .toList(growable: false),
        );
      }

      // Clear cart and notify user
      _service.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thanh toán thành công')));

      // Persist the created order to the shared repository so Profile -> Tải đơn hàng can show it
      OrderRepository.instance.addOrder(createdOrder);

      // Navigate to OrderScreen showing the new order (use a provider seeded from repo)
      final provider = HomeProvider();
      // seed provider.orders from repository when opening
      provider.fetchOrders();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderScreen(provider: provider)),
      );
    }
  }

  int _calculateTotal() {
    final base = _service.totalPrice;
    if (_selectedVoucher == null) return base;
    final v = _selectedVoucher!;
    if (v.percent != null) {
      return base - (base * v.percent! ~/ 100);
    }
    if (v.amount != null) {
      return (base - v.amount!).clamp(0, base);
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final items = _service.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: items.isEmpty
          ? const Center(child: Text('Giỏ hàng trống'))
          : Column(
              children: [
                // Voucher & payment controls (carded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mã giảm giá / Voucher',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ..._vouchers.map(
                                (v) => ChoiceChip(
                                  label: Text(v.code),
                                  selected: _selectedVoucher?.code == v.code,
                                  onSelected: (_) => setState(() {
                                    _selectedVoucher =
                                        _selectedVoucher?.code == v.code
                                        ? null
                                        : v;
                                  }),
                                ),
                              ),
                              ChoiceChip(
                                label: const Text('Không dùng'),
                                selected: _selectedVoucher == null,
                                onSelected: (_) =>
                                    setState(() => _selectedVoucher = null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Phương thức thanh toán',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          RadioListTile<PaymentMethod>(
                            value: PaymentMethod.cod,
                            groupValue: _paymentMethod,
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                            title: const Text('Thanh toán khi nhận hàng (COD)'),
                          ),
                          RadioListTile<PaymentMethod>(
                            value: PaymentMethod.vnpay,
                            groupValue: _paymentMethod,
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                            title: const Text('VNPAY (Sandbox)'),
                            subtitle: const Text(
                              'Thanh toán thử nghiệm (sandbox)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final CartItem it = items[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 72,
                                height: 96,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    it.book.thumbnailUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      it.book.authorText,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _currency.format(it.book.basePrice),
                                      style: const TextStyle(
                                        color: Color(0xFFB7F04A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceVariant,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          onPressed: () =>
                                              _service.updateQuantity(
                                                it.book.id,
                                                it.quantity - 1,
                                              ),
                                          icon: const Icon(Icons.remove),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${it.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          onPressed: () =>
                                              _service.updateQuantity(
                                                it.book.id,
                                                it.quantity + 1,
                                              ),
                                          icon: Icon(
                                            Icons.add,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _currency.format(it.lineTotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng: ${_currency.format(_service.totalPrice)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_selectedVoucher != null)
                              Text(
                                'Sau giảm: ${_currency.format(_calculateTotal())}',
                                style: const TextStyle(color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: _checkout,
                        child: const Text('Thanh toán'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
