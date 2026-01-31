import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that displays the generate button with loading state.
class PresentationGenerateButton extends ConsumerWidget {
  final VoidCallback onGenerate;

  const PresentationGenerateButton({super.key, required this.onGenerate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formState = ref.watch(presentationFormControllerProvider);
    final generateState = ref.watch(presentationGenerateControllerProvider);

    final isLoading = generateState.isLoading;
    final isValid = formState.currentStep == 1
        ? formState.isStep1Valid
        : formState.isStep2Valid;

    final t = ref.watch(translationsPod);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            shape: const StadiumBorder(),
            disabledBackgroundColor: cs.primary.withValues(alpha: 0.5),
          ),
          onPressed: (isValid && !isLoading) ? onGenerate : null,
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                  ),
                )
              : Text(t.generate.customization.generate),
        ),
      ),
    );
  }
}
