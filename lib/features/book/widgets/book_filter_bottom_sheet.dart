import 'package:flutter/material.dart';

import '../../home/models/home_models.dart';
import '../models/book_filter_result.dart';

class BookFilterBottomSheet extends StatefulWidget {
  const BookFilterBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<HomeCategory> categories;
  final Set<String> selectedCategoryIds;
  final double? minPrice;
  final double? maxPrice;

  @override
  State<BookFilterBottomSheet> createState() => _BookFilterBottomSheetState();
}

class _BookFilterBottomSheetState extends State<BookFilterBottomSheet> {
  late Set<String> _categoryIds;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _categoryIds = Set<String>.from(widget.selectedCategoryIds);
    _minController = TextEditingController(text: widget.minPrice?.toStringAsFixed(0) ?? '');
    _maxController = TextEditingController(text: widget.maxPrice?.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('BỘ LỌC', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  Text('Danh mục', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _categoryIds.isEmpty,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tất cả'),
                    onChanged: (value) {
                      if (value == true) {
                        setState(() => _categoryIds.clear());
                      }
                    },
                  ),
                  ...widget.categories.map(
                    (category) {
                      final checked = _categoryIds.contains(category.id);
                      return CheckboxListTile(
                        value: checked,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(category.name),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _categoryIds.add(category.id);
                            } else {
                              _categoryIds.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('Khoảng giá', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Giá từ'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Đến'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _categoryIds.clear();
                        _minController.clear();
                        _maxController.clear();
                      });
                    },
                    child: const Text('ĐẶT LẠI'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        BookFilterResult(
                          categoryIds: _categoryIds,
                          minPrice: double.tryParse(_minController.text.trim()),
                          maxPrice: double.tryParse(_maxController.text.trim()),
                        ),
                      );
                    },
                    child: const Text('ÁP DỤNG'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
