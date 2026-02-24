import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/api_matrix_dto.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_assignment_from_matrix_request.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/generate_full_assignment_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/matrix_template_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/matrix_template_selector_sheet.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/generation/missing_strategy_selector.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/generation_settings_sheet.dart';
import 'package:AIPrimary/features/generate/ui/widgets/generate/option_chip.dart';
import 'package:AIPrimary/features/generate/ui/widgets/options/general_picker_options.dart';
import 'package:AIPrimary/features/generate/ui/widgets/shared/picker_bottom_sheet.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';

enum _AssignmentGenMode { bank, fullAi }

class AssignmentGeneratePage extends ConsumerStatefulWidget {
  const AssignmentGeneratePage({super.key});

  @override
  ConsumerState<AssignmentGeneratePage> createState() =>
      _AssignmentGeneratePageState();
}

class _AssignmentGeneratePageState
    extends ConsumerState<AssignmentGeneratePage> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();

  _AssignmentGenMode _mode = _AssignmentGenMode.bank;
  MatrixTemplateEntity? _selectedTemplate;
  MissingQuestionStrategy _strategy = MissingQuestionStrategy.reportGaps;
  AIModel? _selectedModel;

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty && _selectedTemplate != null;

  Future<void> _handleGenerate() async {
    _titleFocusNode.unfocus();
    if (!_isValid) return;

    final template = _selectedTemplate!;
    final title = _titleController.text.trim();

    if (_mode == _AssignmentGenMode.bank) {
      final req = GenerateAssignmentFromMatrixRequest(
        matrixId: template.id,
        matrix: template.matrix.toDto(),
        subject: template.subject,
        title: title,
        missingStrategy: _strategy.apiValue,
        provider: _selectedModel?.provider,
        model: _selectedModel?.id.toString(),
      );
      await ref
          .read(assignmentGenerationControllerProvider.notifier)
          .generateFromMatrix(req);
    } else {
      final req = GenerateFullAssignmentRequest(
        matrixId: template.id,
        matrix: template.matrix.toDto(),
        title: title,
        provider: _selectedModel?.provider,
        model: _selectedModel?.id.toString(),
      );
      await ref
          .read(assignmentGenerationControllerProvider.notifier)
          .generateFull(req);
    }

    final genState = ref.read(assignmentGenerationControllerProvider);
    if (mounted && genState.hasValue && genState.value != null) {
      context.router.push(const AssignmentDraftReviewRoute());
    }
  }

  void _showStrategyPicker() {
    final t = ref.read(translationsPod);
    PickerBottomSheet.show(
      context: context,
      title: t.assignments.generate.strategy.label,
      child: MissingStrategySelector(
        selected: _strategy,
        onChanged: (s) {
          setState(() => _strategy = s);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAdvancedSettings() {
    final t = ref.read(translationsPod);
    GenerationSettingsSheet.show(
      context: context,
      optionWidgets: const [],
      modelType: ModelType.text,
      title: t.generate.generationSettings.title,
      buttonText: t.generate.generationSettings.done,
      selectedModel: _selectedModel,
      onModelChanged: (model) => setState(() => _selectedModel = model),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final genAsync = ref.watch(assignmentGenerationControllerProvider);
    final isLoading = genAsync.isLoading;
    final error = genAsync.error;

    return Scaffold(
      backgroundColor: Themes.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(context, t, error)),
            _buildBottomBar(context, t, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic t, Object? error) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // 80×80 gradient icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ResourceType.assignment.color.withValues(alpha: 0.8),
                  ResourceType.assignment.color.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              ResourceType.assignment.icon,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            t.assignments.generate.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            t.assignments.generate.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
          ),

          const SizedBox(height: 40),

          // Option chips
          Column(
            children: [
              GeneralPickerOptions.buildOptionsRow(
                context,
                null,
                null,
                [
                  // Mode chip
                  OptionChip(
                    icon: _mode == _AssignmentGenMode.bank
                        ? LucideIcons.database
                        : LucideIcons.sparkles,
                    label: _mode == _AssignmentGenMode.bank
                        ? t.assignments.generate.modeBank
                        : t.assignments.generate.modeFull,
                    onTap: () =>
                        GeneralPickerOptions.showEnumPicker<_AssignmentGenMode>(
                          context: context,
                          title: t.assignments.generate.title,
                          values: _AssignmentGenMode.values,
                          labelOf: (m) => m == _AssignmentGenMode.bank
                              ? t.assignments.generate.modeBank
                              : t.assignments.generate.modeFull,
                          isSelected: (m) => m == _mode,
                          onSelected: (m) => setState(() => _mode = m),
                        ),
                  ),

                  // Template chip
                  OptionChip(
                    icon: LucideIcons.layoutTemplate,
                    label: _selectedTemplate?.name ??
                        t.assignments.generate.noTemplateSelected,
                    onTap: () async {
                      final template =
                          await MatrixTemplateSelectorSheet.show(context);
                      if (template != null) {
                        setState(() => _selectedTemplate = template);
                      }
                    },
                  ),

                  // Strategy chip (bank mode only)
                  if (_mode == _AssignmentGenMode.bank)
                    OptionChip(
                      icon: LucideIcons.settings2,
                      label: _strategy.localizedName(t),
                      onTap: _showStrategyPicker,
                    ),
                ],
                t,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showAdvancedSettings,
                  child: Text(t.generate.advancedSettings),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Error banner
          if (error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    dynamic t,
    bool isLoading,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey[800]
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: t.assignments.form.titleHint,
                    hintStyle: TextStyle(
                      color: context.isDarkMode
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: context.isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: _isValid && !isLoading
                    ? cs.primary
                    : (context.isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[300]),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _isValid && !isLoading ? _handleGenerate : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            color: _isValid ? Colors.white : Colors.grey[500],
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
