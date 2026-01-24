import 'package:datn_mobile/features/classes/states/selection_state.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/resource_selector/resource_tab_bar.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/resource_selector/presentations_list.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/resource_selector/mindmaps_list.dart';
import 'package:flutter/material.dart';

/// Step 1: Resource picker with tabbed interface
///
/// Allows users to browse and select multiple resources
/// from presentations and mindmaps collections
class ResourcePickerStep extends StatefulWidget {
  final Map<String, LinkedResourceSelection> selectedResources;
  final void Function({
    required String id,
    required String title,
    required String type,
  })
  onToggleSelection;

  const ResourcePickerStep({
    super.key,
    required this.selectedResources,
    required this.onToggleSelection,
  });

  @override
  State<ResourcePickerStep> createState() => _ResourcePickerStepState();
}

class _ResourcePickerStepState extends State<ResourcePickerStep> {
  ResourceTab _selectedTab = ResourceTab.presentation;

  void _onTabChanged(ResourceTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        ResourceTabBar(selectedTab: _selectedTab, onTabChanged: _onTabChanged),

        // Tab content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _selectedTab == ResourceTab.presentation
                ? PresentationsList(
                    key: const ValueKey('presentations'),
                    selectedResources: widget.selectedResources,
                    onToggleSelection: widget.onToggleSelection,
                  )
                : MindmapsList(
                    key: const ValueKey('mindmaps'),
                    selectedResources: widget.selectedResources,
                    onToggleSelection: widget.onToggleSelection,
                  ),
          ),
        ),
      ],
    );
  }
}
