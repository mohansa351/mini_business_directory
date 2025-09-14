import 'package:flutter/material.dart';

typedef CardFieldBuilder<T> = Widget Function(BuildContext context, T item);

class BusinessCard<T> extends StatelessWidget {
  final T item;
  final CardFieldBuilder<T> builder;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsets margin;

  const BusinessCard({
    super.key,
    required this.item,
    required this.builder,
    this.onTap,
    this.elevation = 0,
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: builder(context, item),
        ),
      ),
    );
  }
}
