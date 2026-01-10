import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/bank_type_switcher.dart';

/// Header widget for Question Bank page containing bank switcher and search
class QuestionBankHeader extends StatelessWidget {
  final BankType selectedType;
  final ValueChanged<BankType> onTypeChanged;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final VoidCallback onSearchChanged;

  const QuestionBankHeader({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 80, // Space for app bar + title
        bottom: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bank type switcher
          BankTypeSwitcher(
            selectedType: selectedType,
            onTypeChanged: onTypeChanged,
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search questions...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: onSearchCleared,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onSubmitted: onSearchSubmitted,
            onChanged: (_) => onSearchChanged(),
          ),
        ],
      ),
    );
  }
}
