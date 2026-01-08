import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/class_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Sliver app bar with class header and tab navigation.
class ClassDetailAppBar extends StatelessWidget {
  final ClassEntity classEntity;
  final bool isStudent;

  const ClassDetailAppBar({
    super.key,
    required this.classEntity,
    required this.isStudent,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: classEntity.headerColor,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Semantics(
        label: 'Go back',
        button: true,
        hint: 'Double tap to return to classes list',
        child: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.router.maybePop();
          },
          tooltip: 'Back',
        ),
      ),
      actions: [
        Semantics(
          label: 'Class options',
          button: true,
          hint: 'Double tap to see more options',
          child: IconButton(
            icon: const Icon(LucideIcons.ellipsisVertical),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showClassOptions(context);
            },
            tooltip: 'More options',
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          classEntity.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        expandedTitleScale: 1.4,
        titlePadding: const EdgeInsets.all(16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                classEntity.headerColor,
                classEntity.headerColor.withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative pattern
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Class info overlay
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (classEntity.description != null &&
                        classEntity.description!.isNotEmpty)
                      Text(
                        classEntity.description!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.user,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              classEntity.teacherName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.info, color: colorScheme.primary),
              title: const Text('Class Information'),
              onTap: () {
                Navigator.pop(context);
                ClassInfoDialog.show(context, classEntity);
              },
            ),
            if (!isStudent) ...[
              ListTile(
                leading: Icon(LucideIcons.copy, color: colorScheme.primary),
                title: const Text('Copy Join Code'),
                subtitle: Text(classEntity.joinCode ?? 'Not available'),
                onTap: () {
                  Navigator.pop(context);
                  if (classEntity.joinCode != null) {
                    Clipboard.setData(
                      ClipboardData(text: classEntity.joinCode!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Join code copied')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.settings, color: colorScheme.primary),
                title: const Text('Class Settings'),
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(ClassEditRoute(classId: classEntity.id));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
