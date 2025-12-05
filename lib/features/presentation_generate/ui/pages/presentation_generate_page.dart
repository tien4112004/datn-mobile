import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/presentation_generate/states/controller_provider.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Available languages for presentation generation
const List<String> _availableLanguages = ['English', 'Vietnamese'];

/// Available slide counts for presentation generation
const List<int> _availableSlideCounts = [3, 4, 5, 7, 10, 12, 15, 20, 25, 30];

/// Generator types available in the app
enum GeneratorType {
  presentation('Presentation', Icons.slideshow_rounded),
  image('Image', Icons.image_rounded),
  mindmap('Mindmap', Icons.account_tree_rounded);

  final String label;
  final IconData icon;

  const GeneratorType(this.label, this.icon);
}

@RoutePage()
class PresentationGeneratePage extends ConsumerStatefulWidget {
  const PresentationGeneratePage({super.key});

  @override
  ConsumerState<PresentationGeneratePage> createState() =>
      _PresentationGeneratePageState();
}

class _PresentationGeneratePageState
    extends ConsumerState<PresentationGeneratePage> {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _topicFocusNode = FocusNode();
  GeneratorType _selectedGenerator = GeneratorType.presentation;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current topic from state
    final formState = ref.read(presentationFormControllerProvider);
    _topicController.text = formState.topic;

    // Listen for text changes and update state
    _topicController.addListener(_onTopicChanged);

    // Pre-fetch models and set default if not already set
    _initializeDefaultModel();
  }

  Future<void> _initializeDefaultModel() async {
    final formState = ref.read(presentationFormControllerProvider);
    if (formState.outlineModel == null) {
      // Fetch text models and get default
      final modelsState = await ref.read(
        modelsControllerPod(ModelType.text).future,
      );
      final defaultModel = modelsState.availableModels
          .where((m) => m.isDefault && m.isEnabled)
          .firstOrNull;
      if (defaultModel != null && mounted) {
        ref
            .read(presentationFormControllerProvider.notifier)
            .updateOutlineModel(defaultModel);
      }
    }
  }

  @override
  void dispose() {
    _topicController.removeListener(_onTopicChanged);
    _topicController.dispose();
    _topicFocusNode.dispose();
    super.dispose();
  }

  void _onTopicChanged() {
    ref
        .read(presentationFormControllerProvider.notifier)
        .updateTopic(_topicController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    // Listen for generation completion
    ref.listen(presentationGenerateControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          // Check if previous was in loading state (meaning we just completed a request)
          final wasLoading = previous?.isLoading ?? false;
          if (state.outlineResponse != null && wasLoading) {
            // Save outline to form state
            ref
                .read(presentationFormControllerProvider.notifier)
                .setOutline(state.outlineResponse!);
            // Navigate to customization page
            context.router.push(const PresentationCustomizationRoute());
          }
        },
        loading: () {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, isDark),
            // Main Content
            Expanded(child: _buildMainContent(context, isDark)),
            // Bottom Input Section
            _buildBottomInputSection(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Generator type dropdown
          Expanded(child: _buildGeneratorDropdown(context, isDark)),
          IconButton(
            onPressed: _showSettingsBottomSheet,
            icon: Icon(
              Icons.tune_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratorDropdown(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showGeneratorPicker(context, isDark),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _selectedGenerator.icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _selectedGenerator.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ],
      ),
    );
  }

  void _showGeneratorPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Select Generator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          // Options
          ...GeneratorType.values.map((type) {
            final isSelected = _selectedGenerator == type;
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  type.icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              title: Text(
                type.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                _onGeneratorTypeChanged(type);
              },
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  void _onGeneratorTypeChanged(GeneratorType type) {
    if (_selectedGenerator != type) {
      setState(() {
        _selectedGenerator = type;
      });
      // TODO: Navigate to the appropriate generator page or update UI
      // For now, show a snackbar for non-presentation generators
      if (type != GeneratorType.presentation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type.label} generator coming soon!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildMainContent(BuildContext context, bool isDark) {
    final formState = ref.watch(presentationFormControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'AI Presentation Generator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            'Enter your topic and let AI create a professional presentation for you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          // Options Row
          _buildOptionsRow(context, isDark, formState),
          const SizedBox(height: 20),
          // Quick Suggestions
          _buildSuggestions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildOptionsRow(
    BuildContext context,
    bool isDark,
    dynamic formState,
  ) {
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Slide Count
        _buildOptionChip(
          context,
          isDark,
          icon: Icons.format_list_numbered,
          label: '${formState.slideCount} slides',
          onTap: () => _showSlideCountPicker(formController, formState),
        ),
        // Language
        _buildOptionChip(
          context,
          isDark,
          icon: Icons.language,
          label: formState.language,
          onTap: () => _showLanguagePicker(formController, formState),
        ),
        // Model
        _buildOptionChip(
          context,
          isDark,
          icon: Icons.psychology,
          label: formState.outlineModel?.displayName ?? 'Select Model',
          onTap: () => _showModelPicker(formController, formState),
        ),
      ],
    );
  }

  Widget _buildOptionChip(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isDark) {
    final suggestions = [
      'Introduction to Machine Learning',
      'Climate Change Solutions',
      'Digital Marketing Strategies',
      'History of the Internet',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Try these topics:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return InkWell(
              onTap: () {
                _topicController.text = suggestion;
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]?.withValues(alpha: 0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomInputSection(BuildContext context, bool isDark) {
    final formState = ref.watch(presentationFormControllerProvider);
    final generateState = ref.watch(presentationGenerateControllerProvider);
    final isLoading = generateState.maybeWhen(
      data: (state) => state.isLoading,
      loading: () => true,
      orElse: () => false,
    );
    final isValid = formState.isStep1Valid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
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
            // Attach File Button
            Material(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _handleAttachFile,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Text Input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _topicController,
                  focusNode: _topicFocusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Enter your presentation topic...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Generate Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: isValid && !isLoading
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: isValid && !isLoading ? _handleGenerate : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            color: isValid ? Colors.white : Colors.grey[500],
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

  void _handleGenerate() {
    _topicFocusNode.unfocus();
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final outlineData = formController.toOutlineData();
    ref
        .read(presentationGenerateControllerProvider.notifier)
        .generateOutline(outlineData);
  }

  void _handleAttachFile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Attach Files',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          // Options
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.blue),
            ),
            title: const Text('Document'),
            subtitle: const Text('PDF, Word, PowerPoint'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement document picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document picker coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.image_outlined, color: Colors.green),
            ),
            title: const Text('Image'),
            subtitle: const Text('PNG, JPG, GIF'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image picker coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.link_rounded, color: Colors.orange),
            ),
            title: const Text('Link'),
            subtitle: const Text('Website URL'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement link input
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link input coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  void _showSlideCountPicker(dynamic formController, dynamic formState) {
    _showPickerBottomSheet(
      title: 'Number of Slides',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _availableSlideCounts.map((count) {
          final isSelected = formState.slideCount == count;
          return ListTile(
            title: Text('$count slides'),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateSlideCount(count);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showLanguagePicker(dynamic formController, dynamic formState) {
    _showPickerBottomSheet(
      title: 'Language',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _availableLanguages.map((language) {
          final isSelected = formState.language == language;
          return ListTile(
            title: Text(language),
            trailing: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              formController.updateLanguage(language);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showModelPicker(dynamic formController, dynamic formState) {
    final modelsAsync = ref.read(modelsControllerPod(ModelType.text));

    _showPickerBottomSheet(
      title: 'AI Model',
      child: modelsAsync.when(
        data: (state) {
          final models = state.availableModels
              .where((m) => m.isEnabled)
              .toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: models.map((model) {
              final isSelected = formState.outlineModel?.id == model.id;
              return ListTile(
                title: Text(model.displayName),
                subtitle: Text(model.name),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  formController.updateOutlineModel(model);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Failed to load models',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formState = ref.read(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    'Generation Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Slide Count
                  _buildSettingItem(
                    'Number of Slides',
                    isDark,
                    child: DropdownField<int>(
                      value: formState.slideCount,
                      items: _availableSlideCounts,
                      onChanged: (value) {
                        if (value != null) {
                          formController.updateSlideCount(value);
                          setSheetState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Language
                  _buildSettingItem(
                    'Language',
                    isDark,
                    child: DropdownField<String>(
                      value: formState.language,
                      items: _availableLanguages,
                      onChanged: (value) {
                        if (value != null) {
                          formController.updateLanguage(value);
                          setSheetState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Model
                  _buildSettingItem(
                    'AI Model',
                    isDark,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final modelsAsync = ref.watch(
                          modelsControllerPod(ModelType.text),
                        );
                        return modelsAsync.when(
                          data: (state) {
                            final models = state.availableModels
                                .where((m) => m.isEnabled)
                                .toList();
                            if (models.isEmpty) {
                              return const Text('No models available');
                            }
                            final displayNames = models
                                .map((m) => m.displayName)
                                .toList();
                            final currentValue =
                                formState.outlineModel?.displayName ??
                                models.first.displayName;
                            return DropdownField<String>(
                              value: currentValue,
                              items: displayNames,
                              onChanged: (value) {
                                if (value != null) {
                                  final model = models.firstWhere(
                                    (m) => m.displayName == value,
                                  );
                                  formController.updateOutlineModel(model);
                                  setSheetState(() {});
                                }
                              },
                            );
                          },
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          error: (_, _) => const Text('Failed to load models'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingItem(String label, bool isDark, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showPickerBottomSheet({required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    WoltModalSheet.show<void>(
      context: context,
      modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
      useSafeArea: true,
      pageListBuilder: (modelBottomSheetContext) {
        return [
          SliverWoltModalSheetPage(
            trailingNavBarWidget: IconButton(
              onPressed: () => Navigator.pop(modelBottomSheetContext),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            pageTitle: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            mainContentSliversBuilder: (context) => [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(child: child),
              ),
            ],
          ),
        ];
      },
    );
  }
}
