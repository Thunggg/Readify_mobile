import '../home/models/home_models.dart';

class CartItem {
  CartItem({required this.book, this.quantity = 1});

  final HomeBook book;
  int quantity;

  int get lineTotal => (book.basePrice * quantity).toInt();
}
