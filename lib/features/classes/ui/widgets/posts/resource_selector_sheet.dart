import 'package:AIPrimary/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/permission_level.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/resource_selector/resource_picker_step.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/resource_selector/permission_config_step.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/resource_selector/sheet_header.dart';
import 'package:AIPrimary/features/classes/states/resrouce_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Two-step bottom sheet for selecting and configuring linked resources
///
/// Step 1: Pick multiple resources (presentations/mindmaps)
/// Step 2: Configure permissions for each selected resource
///
/// Material 3 Design Features:
/// - Smooth animations with proper easing
/// - Consistent spacing using 8dp grid
/// - Elevated surface hierarchy
/// - Semantic color usage
class ResourceSelectorSheet extends ConsumerStatefulWidget {
  final List<LinkedResourceEntity> alreadySelected;
  final bool assignmentOnly; // True for Exercise posts

  const ResourceSelectorSheet({
    super.key,
    this.alreadySelected = const [],
    this.assignmentOnly = false,
  });

  @override
  ConsumerState<ResourceSelectorSheet> createState() =>
      _ResourceSelectorSheetState();
}

class _ResourceSelectorSheetState extends ConsumerState<ResourceSelectorSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  SelectionStep _currentStep = SelectionStep.pickResources;
  final Map<String, LinkedResourceSelection> _selectedResources = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _prePopulateSelections();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  void _prePopulateSelections() {
    for (final resource in widget.alreadySelected) {
      _selectedResources[resource.id] = LinkedResourceSelection(
        id: resource.id,
        title: '',
        type: resource.type,
        permissionLevel: resource.permissionLevel,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSelection({
    required String id,
    required String title,
    required String type,
  }) {
    setState(() {
      if (_selectedResources.containsKey(id)) {
        _selectedResources.remove(id);
      } else {
        _selectedResources[id] = LinkedResourceSelection(
          id: id,
          title: title,
          type: type,
          permissionLevel: PermissionLevel.view,
        );
      }
    });
  }

  void _updatePermission(String id, PermissionLevel newPermission) {
    setState(() {
      if (_selectedResources.containsKey(id)) {
        _selectedResources[id]!.permissionLevel = newPermission;
      }
    });
  }

  void _removeSelection(String id) {
    setState(() {
      _selectedResources.remove(id);
    });
  }

  Future<void> _proceedToPermissionConfig() async {
    await _animationController.reverse();
    setState(() {
      _currentStep = SelectionStep.configurePermissions;
    });
    _animationController.forward();
  }

  Future<void> _goBackToSelection() async {
    await _animationController.reverse();
    setState(() {
      _currentStep = SelectionStep.pickResources;
    });
    _animationController.forward();
  }

  void _finishSelection() {
    final result = _selectedResources.values
        .map(
          (sel) => LinkedResourceEntity(
            id: sel.id,
            type: sel.type,
            permissionLevel: sel.permissionLevel,
          ),
        )
        .toList();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.8,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(colorScheme),

          // Header
          SheetHeader(
            currentStep: _currentStep,
            selectedCount: _selectedResources.length,
            onClose: () => Navigator.pop(context),
            onBack: _goBackToSelection,
            onContinue: _proceedToPermissionConfig,
            onDone: _finishSelection,
          ),

          const Divider(height: 1),

          // Content with animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _currentStep == SelectionStep.pickResources
                    ? ResourcePickerStep(
                        selectedResources: _selectedResources,
                        onToggleSelection: _toggleSelection,
                        assignmentOnly: widget.assignmentOnly,
                      )
                    : PermissionConfigStep(
                        selectedResources: _selectedResources,
                        onUpdatePermission: _updatePermission,
                        onRemoveSelection: _removeSelection,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
