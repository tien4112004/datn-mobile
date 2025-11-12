import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/shared/widget/attach_box.dart';
import 'package:datn_mobile/shared/widget/option_box.dart';
import 'package:datn_mobile/shared/widget/header_bar.dart';
import 'package:datn_mobile/shared/widget/option_field.dart';
import 'package:datn_mobile/shared/widget/prompt_input_with_suggestions.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});
  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  String model = 'Fast model';
  String grade = 'Grade 1';
  String theme = 'Lorems';
  final TextEditingController describeCtl = TextEditingController();
  final TextEditingController avoidCtl = TextEditingController();
  final TextEditingController slidesCtl = TextEditingController();

  final List<String> chips = const [
    'Introduction to AI and Machine Learning',
    'Climate Change and Environmental Impact',
    'Digital Marketing Strategy',
    'Healthy Lifestyle and Nutrition',
    'History of Ancient Civilizations',
    'Modern Web Development',
    'Financial Planning for Beginners',
    'Space Exploration and Technology',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(
              title: 'Presentation',
              onBack: () => context.router.maybePop(),
              onHelp: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OptionBox(
                      title: 'Options',
                      showInfoDot: true,
                      onInfoTap: () {},
                      collapsedOptions: _buildBasicOptions(),
                      expandedOptions: _buildAdvancedOptions(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Describe your presentation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PromptInputWithSuggestions(
                      controller: describeCtl,
                      hint: 'Describe your video...',
                      suggestions: chips,
                    ),
                    SizedBox(height: describeCtl.text.isEmpty ? 20 : 8),
                    AttachBox(onAdd: () {}),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {},
                  child: const Text('Generate'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<OptionRow> _buildBasicOptions() {
    return [
      OptionRow(
        first: SelectionOption(
          label: 'Model',
          value: model,
          items: const ['Fast model', 'Balanced model', 'Accurate model'],
          onChanged: (v) => setState(() => model = v!),
        ),
        second: TextInputOption(
          label: 'Slides',
          controller: slidesCtl,
          hint: 'Number of slides...',
        ),
      ),
    ];
  }

  List<OptionRow> _buildAdvancedOptions() {
    return [
      OptionRow(
        first: SelectionOption(
          label: 'Grade',
          value: grade,
          items: const ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5'],
          onChanged: (v) => setState(() => grade = v!),
        ),
        second: SelectionOption(
          label: 'Themes',
          value: theme,
          items: const ['Lorems', 'Modern', 'Classic', 'Minimal'],
          onChanged: (v) => setState(() => theme = v!),
        ),
      ),
      OptionRow(
        first: TextInputOption(
          label: 'What to avoid in the image',
          controller: avoidCtl,
          hint: 'Blood, Xuanpac...',
        ),
      ),
    ];
  }
}
