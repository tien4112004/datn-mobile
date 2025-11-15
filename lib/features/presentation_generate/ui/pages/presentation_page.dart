import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/controllers/outline_controller_provider.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/controllers/presentation_generation_controller_provider.dart';
import 'package:datn_mobile/shared/widget/header_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class PresentationPage extends StatelessWidget {
  const PresentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(
              title: 'Presentation',
              onBack: () => context.router.maybePop(),
              onHelp: () {},
            ),
            const Expanded(child: _PresentationFlow()),
          ],
        ),
      ),
    );
  }
}

/// Main flow widget - handles both stages
class _PresentationFlow extends ConsumerWidget {
  const _PresentationFlow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outlineState = ref.watch(generateOutlineControllerProvider);

    return outlineState.when(
      data: (stream) {
        if (stream == null) {
          // Stage 1: Show outline generation form
          return const _OutlineGenerationView();
        } else {
          // Stage 2: Show presentation generation (with outline)
          return const _PresentationGenerationView();
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Stage 1: Generate Outline
class _OutlineGenerationView extends ConsumerStatefulWidget {
  const _OutlineGenerationView();

  @override
  ConsumerState<_OutlineGenerationView> createState() =>
      _OutlineGenerationViewState();
}

class _OutlineGenerationViewState
    extends ConsumerState<_OutlineGenerationView> {
  late final TextEditingController topicCtl;
  late final TextEditingController languageCtl;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(outlineFormControllerProvider);
    topicCtl = TextEditingController(text: formState.topic);
    languageCtl = TextEditingController(text: formState.language);

    topicCtl.addListener(() {
      ref
          .read(outlineFormControllerProvider.notifier)
          .updateTopic(topicCtl.text);
    });

    languageCtl.addListener(() {
      ref
          .read(outlineFormControllerProvider.notifier)
          .updateLanguage(languageCtl.text);
    });
  }

  @override
  void dispose() {
    topicCtl.dispose();
    languageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(outlineFormControllerProvider);
    final formNotifier = ref.read(outlineFormControllerProvider.notifier);
    final generateState = ref.watch(generateOutlineControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage 1: Generate Outline',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: topicCtl,
            decoration: InputDecoration(
              labelText: 'Topic',
              hintText: 'Enter presentation topic...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: languageCtl,
            decoration: InputDecoration(
              labelText: 'Language',
              hintText: 'e.g., en, es, fr...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: formState.slideCount,
            items: List.generate(
              20,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text('${i + 1} slides'),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                formNotifier.updateSlideCount(value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Number of Slides',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          generateState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(generateOutlineControllerProvider.notifier)
                          .generateOutline(formState);
                    },
                    child: const Text('Generate Outline'),
                  ),
                ),
        ],
      ),
    );
  }
}

/// Stage 2: Generate Presentation from Outline
class _PresentationGenerationView extends ConsumerWidget {
  const _PresentationGenerationView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generateOutlineState = ref.watch(generateOutlineControllerProvider);
    final presentationFormState = ref.watch(
      presentationGenerationFormControllerProvider,
    );
    final presentationFormNotifier = ref.read(
      presentationGenerationFormControllerProvider.notifier,
    );
    final generatePresentationState = ref.watch(
      generatePresentationControllerProvider,
    );
    final generatePresentationNotifier = ref.read(
      generatePresentationControllerProvider.notifier,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage 1: Generated Outline',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _StreamingOutlineDisplay(
            stream: generateOutlineState.value,
            onComplete: (fullOutline) {
              // Auto-set outline to presentation form
              presentationFormNotifier.setOutline(fullOutline);
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Stage 2: Generate Presentation',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: presentationFormState.model,
            items: const [
              DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
              DropdownMenuItem(value: 'gpt-3.5', child: Text('GPT-3.5')),
            ],
            onChanged: (value) {
              if (value != null) {
                presentationFormNotifier.updateModel(value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Model',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: presentationFormState.theme,
            items: const [
              DropdownMenuItem(value: 'modern', child: Text('Modern')),
              DropdownMenuItem(value: 'classic', child: Text('Classic')),
              DropdownMenuItem(value: 'minimal', child: Text('Minimal')),
            ],
            onChanged: (value) {
              if (value != null) {
                presentationFormNotifier.updateTheme(value);
              }
            },
            decoration: InputDecoration(
              labelText: 'Theme',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          generatePresentationState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      generatePresentationNotifier.generatePresentation(
                        presentationFormState,
                      );
                    },
                    child: const Text('Generate Presentation'),
                  ),
                ),
          const SizedBox(height: 12),
          if (generatePresentationState.hasValue &&
              generatePresentationState.value != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ Presentation Generated!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Title: ${generatePresentationState.value?.title ?? 'N/A'}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Slides: ${generatePresentationState.value?.slides?.length ?? 0}',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget to display streaming outline in real-time
class _StreamingOutlineDisplay extends StatefulWidget {
  final Stream<String>? stream;
  final Function(String) onComplete;

  const _StreamingOutlineDisplay({
    required this.stream,
    required this.onComplete,
  });

  @override
  State<_StreamingOutlineDisplay> createState() =>
      _StreamingOutlineDisplayState();
}

class _StreamingOutlineDisplayState extends State<_StreamingOutlineDisplay> {
  final StringBuffer _buffer = StringBuffer();
  bool _isStreaming = true;

  @override
  void initState() {
    super.initState();
    if (widget.stream != null) {
      _listenToStream();
    }
  }

  void _listenToStream() {
    widget.stream!.listen(
      (chunk) {
        setState(() {
          _buffer.write(chunk);
        });
      },
      onError: (error) {
        setState(() {
          _isStreaming = false;
        });
      },
      onDone: () {
        setState(() {
          _isStreaming = false;
        });
        widget.onComplete(_buffer.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isStreaming)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Generating outline...'),
              ],
            )
          else
            const Text(
              '✅ Outline complete',
              style: TextStyle(color: Colors.green),
            ),
          const SizedBox(height: 12),
          Text(_buffer.toString(), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
