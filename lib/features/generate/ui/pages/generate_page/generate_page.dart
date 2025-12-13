import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/generate/enum/generator_type.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/pages/generate_page/image_generate_page.dart';
import 'package:datn_mobile/features/generate/ui/pages/generate_page/mindmap_generate_page.dart';
import 'package:datn_mobile/features/generate/ui/pages/generate_page/presentation_generate_page.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/image_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/mindmap_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/presentation_widget_options.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/generator_picker_sheet.dart';
import 'package:datn_mobile/features/generate/ui/widgets/shared/resource_generation_appbar.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class GeneratePage extends ConsumerWidget {
  const GeneratePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final activeGeneratorType = ref.watch(generatorTypeProvider);
    final List<Widget> optionWidgets = switch (activeGeneratorType) {
      GeneratorType.presentation => [
        PresentationWidgetOptions.buildSlideCountSetting(),
      ],
      GeneratorType.mindmap => [
        MindmapWidgetOptions.buildDepthLevelSetting(),
        MindmapWidgetOptions.buildMaxBranchesSetting(),
      ],
      GeneratorType.image => [
        ImageWidgetOptions.buildAspectRatioSetting(),
        ImageWidgetOptions.buildArtStyleSetting(),
        ImageWidgetOptions.buildThemeStyleSetting(),
      ],
    };

    return SafeArea(
      child: Scaffold(
        appBar: ResourceGenerationAppBar(
          onGeneratorTap: () {
            GeneratorPickerSheet.show(context, t);
          },
          t: t,
          optionWidgets: optionWidgets,
        ),
        body: switch (activeGeneratorType) {
          GeneratorType.presentation => const PresentationGeneratePage(),
          GeneratorType.mindmap => const MindmapGeneratePage(),
          GeneratorType.image => const ImageGeneratePage(),
        },
      ),
    );
  }
}
