import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/generate/topic_input_bar.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/attach_file_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/model_picker_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available max depth options for mindmap generation
const List<int> _availableMaxDepths = [1, 2, 3, 4, 5];

/// Available max branches per node options
const List<int> _availableMaxBranches = [2, 3, 4, 5, 6, 7, 8, 9, 10];

/// Available languages for mindmap generation
const List<String> _availableLanguageCodes = ['en', 'vi'];

@RoutePage()
class MindmapGeneratePage extends ConsumerStatefulWidget {
  const MindmapGeneratePage({super.key});

  @override
  ConsumerState<MindmapGeneratePage> createState() =>
      _MindmapGeneratePageState();
}

class _MindmapGeneratePageState extends ConsumerState<MindmapGeneratePage> {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  late final t = ref.watch(translationsPod);

  @override
  void initState() {
    super.initState();
    // Initialize controller with current topic from state
    final formState = ref.read(mindmapFormControllerProvider);
    _topicController.text = formState.topic;

    // Listen for text changes and update state
    _topicController.addListener(_onTopicChanged);

    // Pre-fetch models and set default if not already set
    _initializeDefaultModel();
  }

  Future<void> _initializeDefaultModel() async {
    final formState = ref.read(mindmapFormControllerProvider);
    if (formState.selectedModel == null) {
      // Fetch text models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.text).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(mindmapFormControllerProvider.notifier)
            .updateModel(defaultModel);
      }
    }
  }

  @override
  void dispose() {
    _topicController.removeListener(_onTopicChanged);
    _topicController.dispose();
    _topicFocusNode.dispose();
    super.dispose();
  }

  void _onTopicChanged() {
    ref
        .read(mindmapFormControllerProvider.notifier)
        .updateTopic(_topicController.text);
  }

  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return t.locale_en;
      case 'vi':
        return t.locale_vi;
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Listen for generation completion
    ref.listen(mindmapGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          // Check if a new mindmap was generated
          final hadMindmap =
              previous?.maybeWhen(
                data: (prevState) => prevState.generatedMindmap != null,
                orElse: () => false,
              ) ??
              false;
          final hasNewMindmap = !hadMindmap && state.generatedMindmap != null;

          if (hasNewMindmap) {
            // Navigate to result page
            context.router.push(const MindmapResultRoute());
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          if (context.mounted) {
            SnackbarUtils.showError(
              context,
              t.generate.mindmapGenerate.error(error: error.toString()),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(child: _buildMainContent(context)),
            // Bottom Input Section
            TopicInputBar(
              topicController: _topicController,
              topicFocusNode: _topicFocusNode,
              generateState: mindmapGenerateControllerProvider,
              formState: mindmapFormControllerProvider,
              onAttachFile: () => AttachFileSheet.show(context: context, t: t),
              onGenerate: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final formState = ref.watch(mindmapFormControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            t.generate.mindmapGenerate.pageTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            t.generate.mindmapGenerate.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
          ),
          const SizedBox(height: 40),
          // Options
          _buildOptionsSection(context, formState),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context, dynamic formState) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Language
        _buildOptionChip(
          context,
          icon: Icons.language,
          label: _getLanguageDisplayName(formState.language),
          onTap: () => _showLanguagePicker(formState),
        ),
        // Model
        _buildOptionChip(
          context,
          icon: Icons.psychology,
          label:
              formState.selectedModel?.displayName ??
              t.generate.mindmapGenerate.selectModel,
          onTap: () => _showModelPicker(formState),
        ),
        // Max Depth
        _buildOptionChip(
          context,
          icon: Icons.layers,
          label: t.generate.mindmapGenerate.maxDepth(depth: formState.maxDepth),
          onTap: () => _showMaxDepthPicker(formState),
        ),
        // Max Branches
        _buildOptionChip(
          context,
          icon: Icons.call_split,
          label: t.generate.mindmapGenerate.maxBranches(
            branches: formState.maxBranchesPerNode,
          ),
          onTap: () => _showMaxBranchesPicker(formState),
        ),
      ],
    );
  }

  Widget _buildOptionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: context.secondaryTextColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(dynamic formState) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _availableLanguageCodes.map((code) {
          final isSelected = formState.language == code;
          return ListTile(
            title: Text(_getLanguageDisplayName(code)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              ref
                  .read(mindmapFormControllerProvider.notifier)
                  .updateLanguage(code);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showModelPicker(dynamic formState) {
    ModelPickerSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectModel,
      selectedModelName: formState.selectedModel?.displayName,
      t: t,
      onModelSelected: (model) {
        ref.read(mindmapFormControllerProvider.notifier).updateModel(model);
      },
    );
  }

  void _showMaxDepthPicker(dynamic formState) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectMaxDepth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _availableMaxDepths.map((depth) {
          final isSelected = formState.maxDepth == depth;
          return ListTile(
            title: Text(t.generate.mindmapGenerate.maxDepth(depth: depth)),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              ref
                  .read(mindmapFormControllerProvider.notifier)
                  .updateMaxDepth(depth);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showMaxBranchesPicker(dynamic formState) {
    PickerBottomSheet.show(
      context: context,
      title: t.generate.mindmapGenerate.selectMaxBranches,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _availableMaxBranches.map((branches) {
          final isSelected = formState.maxBranchesPerNode == branches;
          return ListTile(
            title: Text(
              t.generate.mindmapGenerate.maxBranches(branches: branches),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              ref
                  .read(mindmapFormControllerProvider.notifier)
                  .updateMaxBranchesPerNode(branches);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _handleGenerate() {
    _topicFocusNode.unfocus();
    ref.read(mindmapGenerateControllerProvider.notifier).generateMindmap();
  }
}
