import 'package:AIPrimary/features/setting/states/system_prompt_controller.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void showSystemPromptBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _SystemPromptBottomSheet(),
  );
}

class _SystemPromptBottomSheet extends ConsumerStatefulWidget {
  const _SystemPromptBottomSheet();

  @override
  ConsumerState<_SystemPromptBottomSheet> createState() =>
      _SystemPromptBottomSheetState();
}

class _SystemPromptBottomSheetState
    extends ConsumerState<_SystemPromptBottomSheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(systemPromptControllerProvider).value;
    _textController = TextEditingController(text: existing?.prompt ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final promptState = ref.watch(systemPromptControllerProvider);
    final isLoading = promptState.isLoading;
    final hasExisting = promptState.value != null;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(systemPromptControllerProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.systemPrompt.errorSaving)),
        );
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title row
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                t.settings.systemPrompt.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.settings.systemPrompt.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Text field with character counter
          ValueListenableBuilder(
            valueListenable: _textController,
            builder: (context, value, _) {
              final charCount = value.text.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: 6,
                    maxLength: 2000,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                    decoration: InputDecoration(
                      hintText: t.settings.systemPrompt.placeholder,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$charCount/2000',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: charCount > 1900
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Buttons row
          ValueListenableBuilder(
            valueListenable: _textController,
            builder: (context, value, _) {
              final isEmpty = value.text.trim().isEmpty;
              return Row(
                children: [
                  if (hasExisting) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () async {
                                await ref
                                    .read(
                                      systemPromptControllerProvider.notifier,
                                    )
                                    .deletePrompt();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        t.settings.systemPrompt.deleteSuccess,
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.trash2, size: 16),
                        label: Text(t.settings.systemPrompt.delete),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading || isEmpty
                          ? null
                          : () async {
                              await ref
                                  .read(systemPromptControllerProvider.notifier)
                                  .upsertPrompt(_textController.text.trim());
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t.settings.systemPrompt.saveSuccess,
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(LucideIcons.check, size: 16),
                      label: Text(t.settings.systemPrompt.save),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
