import 'package:flutter/material.dart';

class ArtStylePicker extends StatelessWidget {
  final String selectedArtStyle;
  final List<String> availableArtStyles;
  final ValueChanged<String> onStyleSelected;
  final Map<String, Color> styleColors;
  final Map<String, IconData> styleIcons;

  const ArtStylePicker({
    super.key,
    required this.selectedArtStyle,
    required this.availableArtStyles,
    required this.onStyleSelected,
    required this.styleColors,
    required this.styleIcons,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.85,
        children: availableArtStyles.map((style) {
          final isSelected = selectedArtStyle == style;
          final color = styleColors[style] ?? Colors.grey;
          final icon = styleIcons[style] ?? Icons.palette;

          return GestureDetector(
            onTap: () => onStyleSelected(style),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 40),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  style.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
