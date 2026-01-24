import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';

enum ResourceTab { presentation, mindmap }

enum SelectionStep { pickResources, configurePermissions }

/// Represents a selected resource with its configuration
class LinkedResourceSelection {
  final String id;
  final String title;
  final String type;
  PermissionLevel permissionLevel;

  LinkedResourceSelection({
    required this.id,
    required this.title,
    required this.type,
    this.permissionLevel = PermissionLevel.view,
  });

  LinkedResourceSelection copyWith({
    String? id,
    String? title,
    String? type,
    PermissionLevel? permissionLevel,
  }) {
    return LinkedResourceSelection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      permissionLevel: permissionLevel ?? this.permissionLevel,
    );
  }
}

class SelectionState {
  final List<LinkedResourceSelection> selectedResources;
  final SelectionStep currentStep;

  SelectionState({
    this.selectedResources = const [],
    this.currentStep = SelectionStep.pickResources,
  });

  SelectionState copyWith({
    List<LinkedResourceSelection>? selectedResources,
    SelectionStep? currentStep,
  }) {
    return SelectionState(
      selectedResources: selectedResources ?? this.selectedResources,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
