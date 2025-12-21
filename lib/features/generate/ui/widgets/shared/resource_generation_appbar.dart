import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/enum/generator_type.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// App bar widget for presentation generation page
/// Displays generator type selector and settings button
class ResourceGenerationAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onGeneratorTap;
  final Translations t;

  const ResourceGenerationAppBar({
    super.key,
    required this.onGeneratorTap,
    required this.t,
  });

  @override
  State<ResourceGenerationAppBar> createState() =>
      _ResourceGenerationAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ResourceGenerationAppBarState extends State<ResourceGenerationAppBar> {
  final GeneratorType selectedGenerator = GeneratorType.presentation;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ThemeDecorations.containerWithBottomBorder(context),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(LucideIcons.arrowLeft, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Generator type dropdown
          Expanded(child: _buildGeneratorDropdown(context)),
        ],
      ),
    );
  }

  Widget _buildGeneratorDropdown(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final selectedGenerator = ref.watch(generatorTypeProvider);
        return GestureDetector(
          onTap: widget.onGeneratorTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedGenerator.icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                selectedGenerator.getLabel(widget.t),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
