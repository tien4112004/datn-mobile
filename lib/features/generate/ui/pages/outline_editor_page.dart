import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/outline_editor_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class OutlineEditorPage extends ConsumerStatefulWidget {
  const OutlineEditorPage({super.key});

  @override
  ConsumerState<OutlineEditorPage> createState() => _OutlineEditorPageState();
}

class _OutlineEditorPageState extends ConsumerState<OutlineEditorPage> {
  @override
  Widget build(BuildContext context) {
    final editingState = ref.watch(outlineEditingControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? null
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(
              context,
              Theme.of(context).brightness == Brightness.dark,
            ),
            Expanded(
              child: editingState.slides.isEmpty
                  ? const EmptyOutlineView()
                  : const OutlineSlidesList(),
            ),
            const OutlineActionsBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _handleBack(
              ref.read(outlineEditingControllerProvider.notifier),
            ),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Generator type dropdown
          Expanded(
            child: Text(
              'Edit Outline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack(OutlineEditingController controller) {
    // Auto-save and pop without confirmation
    _saveOutline();
    context.router.maybePop();
  }

  void _saveOutline() {
    final editingController = ref.read(
      outlineEditingControllerProvider.notifier,
    );
    final markdownOutline = editingController.getMarkdownOutline();
    ref
        .read(presentationFormControllerProvider.notifier)
        .setOutline(markdownOutline);
  }
}
