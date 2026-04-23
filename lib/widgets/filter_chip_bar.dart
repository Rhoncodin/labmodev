import 'package:flutter/material.dart';

class FilterChipBar<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T option) labelBuilder;
  final ValueChanged<T> onSelected;

  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;

          return ChoiceChip(
            label: Text(labelBuilder(option)),
            selected: isSelected,
            onSelected: (_) => onSelected(option),
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            selectedColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF1E4FA1) : Colors.white,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          );
        },
      ),
    );
  }
}
