import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class MindmapResultPage extends ConsumerWidget {
  const MindmapResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final generateState = ref.watch(mindmapGenerateControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, t),
            // Content
            Expanded(
              child: generateState.when(
                data: (state) {
                  if (state.generatedMindmap == null) {
                    return Center(
                      child: Text(t.generate.mindmapResult.noMindmap),
                    );
                  }
                  return _buildMindmapContent(
                    context,
                    state.generatedMindmap!,
                    t,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    t.generate.mindmapResult.error(error: error.toString()),
                  ),
                ),
              ),
            ),
            // Bottom Actions
            _buildBottomActions(context, ref, t),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Translations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ThemeDecorations.containerWithBottomBorder(context),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.account_tree_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            t.generate.mindmapResult.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMindmapContent(
    BuildContext context,
    MindmapNodeContent root,
    Translations t,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Root node header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.hub, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                Text(
                  root.content,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Children nodes
          if (root.children.isNotEmpty) ...[
            Text(
              t.generate.mindmapResult.branches,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 12),
            ...root.children.asMap().entries.map((entry) {
              return _buildBranchNode(context, entry.value, 0, entry.key);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchNode(
    BuildContext context,
    MindmapNodeContent node,
    int depth,
    int index,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(left: depth * 16.0, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    node.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.isDarkMode
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ),
                if (node.children.isNotEmpty)
                  Icon(
                    Icons.subdirectory_arrow_right,
                    size: 16,
                    color: context.secondaryTextColor,
                  ),
              ],
            ),
          ),
          if (node.children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Column(
                children: node.children.asMap().entries.map((entry) {
                  return _buildBranchNode(
                    context,
                    entry.value,
                    depth + 1,
                    entry.key,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    Translations t,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: ThemeDecorations.containerWithTopBorder(context),
      child: Row(
        children: [
          // Generate New
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(mindmapGenerateControllerProvider.notifier).reset();
                ref.read(mindmapFormControllerProvider.notifier).reset();
                context.router.maybePop();
              },
              icon: const Icon(Icons.refresh),
              label: Text(t.generate.mindmapResult.generateNew),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Save Mindmap
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement save to server
                SnackbarUtils.showInfo(
                  context,
                  t.generate.mindmapResult.saveComingSoon,
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(t.generate.mindmapResult.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
