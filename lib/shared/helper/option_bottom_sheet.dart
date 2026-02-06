import 'package:AIPrimary/shared/helper/global_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic bottom sheet for selecting from a list of options
class OptionBottomSheet<T> extends ConsumerStatefulWidget {
  const OptionBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onOptionSelected,
    this.getOptionLabel,
    this.getOptionIcon,
    this.getOptionDescription,
    this.showLoadingOverlay = false,
    this.overlayDelay = const Duration(milliseconds: 300),
  });

  /// The title displayed at the top of the bottom sheet
  final String title;

  /// List of available options
  final List<T> options;

  /// The currently selected value
  final T currentValue;

  /// Callback when an option is selected
  final Future<void> Function(T value) onOptionSelected;

  /// Function to get the display label for an option
  /// If not provided, uses toString()
  final String Function(T option)? getOptionLabel;

  /// Function to get the icon for an option
  final IconData Function(T option)? getOptionIcon;

  /// Function to get the description for an option
  final String? Function(T option)? getOptionDescription;

  /// Whether to show a loading overlay during option selection
  final bool showLoadingOverlay;

  /// Duration to show the loading overlay
  final Duration overlayDelay;

  @override
  ConsumerState<OptionBottomSheet<T>> createState() =>
      _OptionBottomSheetState<T>();
}

class _OptionBottomSheetState<T> extends ConsumerState<OptionBottomSheet<T>>
    with GlobalHelper<OptionBottomSheet<T>> {
  Future<void> _handleOptionTap(T option, String loadingText) async {
    if (widget.showLoadingOverlay) {
      // Show loading overlay
      showCustomOverlay(
        context: context,
        builder: (context) => ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    loadingText,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Execute the callback
      await widget.onOptionSelected(option);

      // Wait for the specified delay
      await Future.delayed(widget.overlayDelay);

      // Hide overlay
      // hideOverlay();
    } else {
      await widget.onOptionSelected(option);
    }

    if (mounted && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = ref.watch(translationsPod);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ...widget.options.map((option) {
              final isSelected = option == widget.currentValue;
              final label =
                  widget.getOptionLabel?.call(option) ?? option.toString();
              final icon = widget.getOptionIcon?.call(option);
              final description = widget.getOptionDescription?.call(option);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: icon != null
                    ? Icon(
                        icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).iconTheme.color,
                      )
                    : null,
                title: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: description != null
                    ? Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => _handleOptionTap(option, translation.loading),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show an option bottom sheet
Future<void> showOptionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required T currentValue,
  required Future<void> Function(T value) onOptionSelected,
  String Function(T option)? getOptionLabel,
  IconData Function(T option)? getOptionIcon,
  String? Function(T option)? getOptionDescription,
  bool showLoadingOverlay = false,
  Duration overlayDelay = const Duration(milliseconds: 300),
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => OptionBottomSheet<T>(
      title: title,
      options: options,
      currentValue: currentValue,
      onOptionSelected: onOptionSelected,
      getOptionLabel: getOptionLabel,
      getOptionIcon: getOptionIcon,
      getOptionDescription: getOptionDescription,
      showLoadingOverlay: showLoadingOverlay,
      overlayDelay: overlayDelay,
    ),
  );
}
