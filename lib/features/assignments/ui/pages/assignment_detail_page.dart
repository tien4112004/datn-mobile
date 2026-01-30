import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_update_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/assessment_matrix_dashboard.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/bottom_action_dock.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/floating_action_menu.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/metadata_tab.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/tabs/questions_tab.dart';
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
      length: 3,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(LucideIcons.circle, color: colorScheme.error, size: 32),
        title: const Text('Delete Question'),
        content: Text(
          'Are you sure you want to delete question ${questionIndex + 1}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Delete'),
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

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Question deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentAsync = ref.watch(
      detailAssignmentControllerProvider(widget.assignmentId),
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
                    'Assignment Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    // Edit Mode Toggle
                    IconButton(
                      icon: Icon(
                        _isEditMode ? LucideIcons.eye : LucideIcons.pencil,
                        size: 20,
                      ),
                      onPressed: () {
                        if (!_isSaving) {
                          HapticFeedback.lightImpact();
                          setState(() => _isEditMode = !_isEditMode);
                        }
                      },
                      tooltip: _isEditMode ? 'View Mode' : 'Edit Mode',
                    ),
                    const SizedBox(width: 8),
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
                  onSwitchMode: () =>
                      setState(() => _isEditMode = !_isEditMode),
                  onEdit: (questionEntity, index) async {
                    // Navigate to edit page using router
                    final result = await context.router.push<dynamic>(
                      AssignmentQuestionEditRoute(
                        questionEntity: questionEntity,
                        questionNumber: index + 1,
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

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Question deleted'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else if (result is AssignmentQuestionEntity) {
                        // Question was updated
                        await ref
                            .read(
                              detailAssignmentControllerProvider(
                                widget.assignmentId,
                              ).notifier,
                            )
                            .updateQuestion(index, result);

                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Question updated'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  },
                  onDelete: (index) {
                    _showDeleteConfirmation(context, index);
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
                    // Capture context before async operations
                    final navigator = context.router;

                    // Navigate to question bank picker (now returns AssignmentQuestionEntity with points)
                    final assignmentQuestions = await navigator
                        .push<List<AssignmentQuestionEntity>>(
                          const QuestionBankPickerRoute(),
                        );

                    if (assignmentQuestions != null && mounted) {
                      // Add questions to assignment
                      await ref
                          .read(
                            detailAssignmentControllerProvider(
                              widget.assignmentId,
                            ).notifier,
                          )
                          .addQuestions(assignmentQuestions);

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${assignmentQuestions.length} question(s)',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  onCreateNew: () async {
                    // Navigate to question create page for assignment
                    final result = await context.router
                        .push<AssignmentQuestionEntity>(
                          AssignmentQuestionCreateRoute(defaultPoints: 10.0),
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

                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Question created and added'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                )
              : null,

          // Bottom Navigation Bar with TabBar and conditional BottomActionDock
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom Action Dock (only in edit mode)
              if (_isEditMode)
                BottomActionDock(
                  onCancel: () {
                    setState(() => _isEditMode = false);
                    // Refresh to discard any local optimistic changes
                    ref
                        .read(
                          detailAssignmentControllerProvider(
                            widget.assignmentId,
                          ).notifier,
                        )
                        .refresh();
                  },
                  onSave: () async {
                    setState(() => _isSaving = true);

                    try {
                      // Get current assignment state to sync all fields
                      final currentAssignment = assignment;

                      // Create update request with all current values including questions
                      final request = AssignmentUpdateRequest(
                        title: currentAssignment.title,
                        description: currentAssignment.description,
                        duration: currentAssignment.timeLimitMinutes,
                        subject: currentAssignment.subject.apiValue,
                        grade: currentAssignment.gradeLevel.apiValue,
                        questions: currentAssignment.questions
                            .map((q) => q.toRequest())
                            .toList(),
                      );

                      // Sync to server
                      await ref
                          .read(updateAssignmentControllerProvider.notifier)
                          .updateAssignment(widget.assignmentId, request);

                      // Refresh to get latest server state
                      await ref
                          .read(
                            detailAssignmentControllerProvider(
                              widget.assignmentId,
                            ).notifier,
                          )
                          .refresh();

                      if (mounted) {
                        setState(() {
                          _isSaving = false;
                          _isEditMode = false;
                        });

                        if (!context.mounted) return;

                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Assignment saved successfully'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (error) {
                      if (mounted) {
                        setState(() => _isSaving = false);

                        if (!context.mounted) return;

                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Error saving assignment: $error'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  isSaving: _isSaving,
                ),
              // TabBar (always visible)
              Container(
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
                    tabs: const [
                      Tab(
                        text: 'INFO',
                        icon: Icon(LucideIcons.info, size: 20),
                        iconMargin: EdgeInsets.only(bottom: 4),
                      ),
                      Tab(
                        text: 'QUESTIONS',
                        icon: Icon(LucideIcons.listOrdered, size: 20),
                        iconMargin: EdgeInsets.only(bottom: 4),
                      ),
                      Tab(
                        text: 'MATRIX',
                        icon: Icon(LucideIcons.grid3x3, size: 20),
                        iconMargin: EdgeInsets.only(bottom: 4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
