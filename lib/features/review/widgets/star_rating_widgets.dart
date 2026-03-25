import 'package:flutter/material.dart';

class StarRatingInput extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  final double size;
  final Color? color;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(Size(size + 8, size + 8)),
          icon: Icon(
            starValue <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: starValue <= rating ? (color ?? const Color(0xFFB7F04A)) : Colors.grey[600],
          ),
          onPressed: () => onChanged(starValue),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        if (starValue <= rating) {
          return Icon(Icons.star_rounded, size: size, color: color ?? const Color(0xFFB7F04A));
        } else if (starValue - 0.5 <= rating) {
          return Icon(Icons.star_half_rounded, size: size, color: color ?? const Color(0xFFB7F04A));
        } else {
          return Icon(Icons.star_outline_rounded, size: size, color: Colors.grey[600]);
        }
      }),
    );
  }
}
