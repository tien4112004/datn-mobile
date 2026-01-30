import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/core/theme/theme_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

///This class provider segmented button which can be used
///for getting current theme and switching theme
final themeSelectionPod = Provider.autoDispose<Set<ThemeMode>>(
  (ref) => <ThemeMode>{ref.watch(themeControllerProvider)},
  name: "themeSelectionPod",
);

class ThemeSegmentedBtn extends ConsumerStatefulWidget {
  const ThemeSegmentedBtn({super.key});

  @override
  ConsumerState<ThemeSegmentedBtn> createState() => _ThemeSegmentedBtnState();
}

class _ThemeSegmentedBtnState extends ConsumerState<ThemeSegmentedBtn> {
  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.light,
          icon: Icon(LucideIcons.sun),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.dark,
          icon: Icon(LucideIcons.moon),
        ),
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          icon: Icon(LucideIcons.monitor),
        ),
      ],
      selected: ref.watch(themeSelectionPod),
      onSelectionChanged: (thememodes) {
        ref
            .read(themeControllerProvider.notifier)
            .changeTheme(thememodes.first);
      },
      style: const ButtonStyle(
        maximumSize: WidgetStatePropertyAll(Size.fromWidth(12)),
      ),
    );
  }
}
