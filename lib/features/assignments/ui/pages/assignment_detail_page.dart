import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/assessment_matrix_dashboard.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/floating_action_menu.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/metadata_tab.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/questions_tab.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/contexts_tab.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/matrix_tab.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Comprehensive Assignment Detail & Edit Page with Tabbed Layout.
/// Follows Material Design 3 guidelines with clean component separation.
///
/// Features:
/// - Three tabs: Metadata, Questions, Matrix
/// - Sticky app bar with edit mode toggle
/// - Tab-specific content organization
/// - Bottom action dock for save/cancel (edit mode)
/// - Floating action button for adding questions (Questions tab only, edit mode)
/// - Smooth tab transitions with haptic feedback
@RoutePage()
class AssignmentDetailPage extends ConsumerStatefulWidget {
  final String assignmentId;

  const AssignmentDetailPage({
    super.key,
    @PathParam('assignmentId') required this.assignmentId,
  });

  @override
  ConsumerState<AssignmentDetailPage> createState() =>
      _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends ConsumerState<AssignmentDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isEditMode = false;
  bool _isSaving = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 1, // Start on Questions tab
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
      // Rebuild for FAB visibility update when tab changes
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Calculate assessment matrix from assignment questions.
  AssessmentMatrix _calculateAssessmentMatrix(AssignmentEntity assignment) {
    // Count actual questions by type and difficulty
    final Map<String, int> actualMatrix = {};

    for (final questionEntity in assignment.questions) {
      final question = questionEntity.question;
      final key = '${question.type.name}_${question.difficulty.name}';

      actualMatrix[key] = (actualMatrix[key] ?? 0) + 1;
    }

    // For now, targetMatrix is empty since there's no UI to set targets yet
    // In the future, this should come from assignment.targetMatrix or similar
    final Map<String, int> targetMatrix = {};

    return AssessmentMatrix(
      targetMatrix: targetMatrix,
      actualMatrix: actualMatrix,
    );
  }

  void _showDeleteConfirmation(BuildContext context, int questionIndex) async {
    final t = ref.read(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.circle, color: colorScheme.error, size: 32),
        title: Text(t.assignments.detail.deleteQuestion.title),
        content: Text(
          t.assignments.detail.deleteQuestion.message(
            number: questionIndex + 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.assignments.detail.deleteQuestion.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text(t.assignments.detail.deleteQuestion.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(
            detailAssignmentControllerProvider(widget.assignmentId).notifier,
          )
          .removeQuestion(questionIndex);
    }
  }

  /// Handles editing a context — navigates to full-screen edit page.
  Future<void> _handleEditContext(ContextEntity contextEntity) async {
    final result = await context.router.push<dynamic>(
      ContextEditRoute(context: contextEntity),
    );

    if (!mounted) return;

    if (result == 'UNLINK') {
      // User chose to unlink from the edit page
      await _handleUnlinkContext(contextEntity.id);
    } else if (result is ContextEntity) {
      // Context was updated
      await ref
          .read(
            assignmentContextsControllerProvider(widget.assignmentId).notifier,
          )
          .updateContext(result);
    }
  }

  /// Handles unlinking a context — clears contextId from questions and removes context.
  Future<void> _handleUnlinkContext(String contextId) async {
    // Clear contextId from all questions referencing this context
    await ref
        .read(detailAssignmentControllerProvider(widget.assignmentId).notifier)
        .clearContextIdFromQuestions(contextId);

    // Remove context from the contexts list
    await ref
        .read(
          assignmentContextsControllerProvider(widget.assignmentId).notifier,
        )
        .removeContext(contextId);
  }

  void _handleCancel() {
    setState(() => _isEditMode = false);
    ref
        .read(detailAssignmentControllerProvider(widget.assignmentId).notifier)
        .refresh();
  }

  Future<void> _handleSave(AssignmentEntity assignment) async {
    setState(() => _isSaving = true);

    try {
      final contexts =
          ref
              .read(assignmentContextsControllerProvider(widget.assignmentId))
              .value ??
          [];

      final request = AssignmentUpdateRequest(
        title: assignment.title,
        description: assignment.description,
        duration: assignment.timeLimitMinutes,
        subject: assignment.subject.apiValue,
        grade: assignment.gradeLevel.apiValue,
        questions: assignment.questions.map((q) => q.toRequest()).toList(),
        contexts: contexts.map((c) => c.toRequest()).toList(),
      );

      await ref
          .read(updateAssignmentControllerProvider.notifier)
          .updateAssignment(widget.assignmentId, request);

      await ref
          .read(
            detailAssignmentControllerProvider(widget.assignmentId).notifier,
          )
          .refresh();

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditMode = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);

        final t = ref.read(translationsPod);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.assignments.detail.saveError(error: error.toString()),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentAsync = ref.watch(
      detailAssignmentControllerProvider(widget.assignmentId),
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Watch contexts for this assignment
    final contextsAsync = ref.watch(
      assignmentContextsControllerProvider(widget.assignmentId),
    );

    // Build contextsMap from loaded contexts (empty map if loading/error)
    final contextsMap = <String, ContextEntity>{};
    contextsAsync.whenData((contexts) {
      for (final ctx in contexts) {
        contextsMap[ctx.id] = ctx;
      }
    });

    return assignmentAsync.easyWhen(
      data: (assignment) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Sticky App Bar
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: colorScheme.surfaceTint,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.router.maybePop(),
                  ),
                  title: Text(
                    t.assignments.assignmentDetails,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: _isEditMode
                      ? [
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: _isSaving ? null : _handleCancel,
                            tooltip: t.assignments.actionDock.cancel,
                          ),
                          _isSaving
                              ? Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    LucideIcons.save,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  onPressed: () => _handleSave(assignment),
                                  tooltip: t.assignments.actionDock.saveChanges,
                                ),
                          const SizedBox(width: 4),
                        ]
                      : [
                          IconButton(
                            icon: Icon(
                              LucideIcons.pencil,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() => _isEditMode = true);
                            },
                            tooltip: t.assignments.editMode,
                          ),
                          const SizedBox(width: 4),
                        ],
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // Metadata Tab
                MetadataTab(
                  assignment: assignment,
                  isEditMode: _isEditMode,
                  onShuffleChanged: _isEditMode
                      ? (value) async {
                          await ref
                              .read(
                                detailAssignmentControllerProvider(
                                  widget.assignmentId,
                                ).notifier,
                              )
                              .updateShuffleQuestions(value);
                        }
                      : null,
                ),
                // Questions Tab
                QuestionsTab(
                  assignment: assignment,
                  isEditMode: _isEditMode,
                  contextsMap: contextsMap,
                  onEditContext: _isEditMode
                      ? (contextEntity) => _handleEditContext(contextEntity)
                      : null,
                  onSwitchMode: () =>
                      setState(() => _isEditMode = !_isEditMode),
                  onEdit: (questionEntity, index) async {
                    // Navigate to edit page using router
                    final result = await context.router.push<dynamic>(
                      AssignmentQuestionEditRoute(
                        questionEntity: questionEntity,
                        questionNumber: index + 1,
                        assignmentContexts: contextsMap.values.toList(),
                      ),
                    );

                    // Handle result
                    if (result != null && mounted) {
                      if (result == 'DELETE') {
                        // Question was deleted in edit page
                        await ref
                            .read(
                              detailAssignmentControllerProvider(
                                widget.assignmentId,
                              ).notifier,
                            )
                            .removeQuestion(index);
                      } else if (result is AssignmentQuestionEntity) {
                        // Question was updated
                        await ref
                            .read(
                              detailAssignmentControllerProvider(
                                widget.assignmentId,
                              ).notifier,
                            )
                            .updateQuestion(index, result);
                      }
                    }
                  },
                  onDelete: (index) {
                    _showDeleteConfirmation(context, index);
                  },
                ),
                // Contexts (Passages) Tab
                ContextsTab(
                  assignment: assignment,
                  contexts: contextsMap.values.toList(),
                  isEditMode: _isEditMode,
                  onCreateContext: (contextEntity) async {
                    await ref
                        .read(
                          assignmentContextsControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .addContext(contextEntity);
                  },
                  onImportContext: (sourceContext) async {
                    final cloned = ref
                        .read(
                          assignmentContextsControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .cloneContext(sourceContext);

                    await ref
                        .read(
                          assignmentContextsControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .addContext(cloned);
                  },
                  onEditContext: (contextEntity) =>
                      _handleEditContext(contextEntity),
                  onDeleteContext: (contextId) async {
                    // Clear contextId from all questions referencing this context
                    await ref
                        .read(
                          detailAssignmentControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .clearContextIdFromQuestions(contextId);

                    // Remove context from the contexts list
                    await ref
                        .read(
                          assignmentContextsControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .removeContext(contextId);
                  },
                ),
                // Matrix Tab
                MatrixTab(
                  matrix: _calculateAssessmentMatrix(assignment),
                  isEditMode: _isEditMode,
                ),
              ],
            ),
          ),

          // Floating Action Menu (only in edit mode and Questions tab)
          floatingActionButton: _isEditMode && _tabController.index == 1
              ? FloatingActionMenu(
                  onAddFromBank: () async {
                    final navigator = context.router;

                    // Navigate to question bank picker
                    final assignmentQuestions = await navigator
                        .push<List<AssignmentQuestionEntity>>(
                          const QuestionBankPickerRoute(),
                        );

                    if (assignmentQuestions == null || !mounted) return;

                    // Extract unique contextIds from selected questions
                    final contextIds = assignmentQuestions
                        .where((q) => q.contextId != null)
                        .map((q) => q.contextId!)
                        .toSet()
                        .toList();

                    // No contexts — add questions directly
                    if (contextIds.isEmpty) {
                      await ref
                          .read(
                            detailAssignmentControllerProvider(
                              widget.assignmentId,
                            ).notifier,
                          )
                          .addQuestions(assignmentQuestions);
                      return;
                    }

                    // Contexts exist — fetch and clone them
                    List<ContextEntity> fetchedContexts;
                    try {
                      final repository = ref.read(contextRepositoryProvider);
                      fetchedContexts = await repository.getContextsByIds(
                        contextIds,
                      );
                    } catch (e) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to fetch context details: $e',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return;
                    }

                    if (!mounted) return;

                    // Clone contexts and build ID mapping
                    final contextIdMap = <String, String>{};
                    final contextController = ref.read(
                      assignmentContextsControllerProvider(
                        widget.assignmentId,
                      ).notifier,
                    );

                    for (final sourceContext in fetchedContexts) {
                      final cloned = contextController.cloneContext(
                        sourceContext,
                      );
                      await contextController.addContext(cloned);
                      contextIdMap[sourceContext.id] = cloned.id;
                    }

                    // Remap contextIds in questions
                    final remappedQuestions = assignmentQuestions.map((q) {
                      if (q.contextId != null &&
                          contextIdMap.containsKey(q.contextId)) {
                        return q.copyWith(contextId: contextIdMap[q.contextId]);
                      }
                      return q;
                    }).toList();

                    // Add questions with remapped contextIds
                    await ref
                        .read(
                          detailAssignmentControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .addQuestions(remappedQuestions);
                  },
                  onCreateNew: () async {
                    // Navigate to question create page for assignment
                    final result = await context.router
                        .push<AssignmentQuestionEntity>(
                          AssignmentQuestionCreateRoute(
                            defaultPoints: 10.0,
                            assignmentContexts: contextsMap.values.toList(),
                          ),
                        );

                    if (result != null && mounted) {
                      // Add the new question to assignment
                      await ref
                          .read(
                            detailAssignmentControllerProvider(
                              widget.assignmentId,
                            ).notifier,
                          )
                          .addQuestions([result]);
                    }
                  },
                )
              : null,

          // Bottom Navigation Bar with TabBar only
          bottomNavigationBar: Container(
            color: colorScheme.surface,
            child: SafeArea(
              child: TabBar(
                controller: _tabController,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                tabs: [
                  Tab(
                    text: t.assignments.detail.tabs.info,
                    icon: const Icon(LucideIcons.info, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: t.assignments.detail.tabs.questions,
                    icon: const Icon(LucideIcons.listOrdered, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: t.assignments.detail.tabs.passages,
                    icon: const Icon(LucideIcons.bookOpen, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                  Tab(
                    text: t.assignments.detail.tabs.matrix,
                    icon: const Icon(LucideIcons.grid3x3, size: 20),
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
