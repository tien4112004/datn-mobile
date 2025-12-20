import 'package:datn_mobile/features/generate/data/dto/art_style_dto.dart';
import 'package:flutter/material.dart';

class ArtStylePicker extends StatelessWidget {
  final String selectedArtStyleId;
  final List<ArtStyleDto> artStyles;
  final ValueChanged<String> onStyleSelected;

  const ArtStylePicker({
    super.key,
    required this.selectedArtStyleId,
    required this.artStyles,
    required this.onStyleSelected,
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
        children: artStyles.map((artStyle) {
          final isSelected = selectedArtStyleId == artStyle.id;

          return GestureDetector(
            onTap: () => onStyleSelected(artStyle.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (artStyle.visual != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.network(
                              artStyle.visual!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.palette,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.palette,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
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
                  artStyle.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
