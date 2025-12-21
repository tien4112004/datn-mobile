import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({super.key});

  // Mock url
  // final String imageUrl;
  final String _imageUrl =
      "https://claritycareconsulting.co.uk/wp-content/uploads/et_temp/Blank-Profile-Picture-34126_1080x675.jpg";

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.network(_imageUrl, fit: BoxFit.cover),
    );
  }
}

class DefaultThumbnail extends StatelessWidget {
  const DefaultThumbnail({super.key, required this.resourceType});

  final ResourceType resourceType;

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(resourceType.icon, color: resourceType.color));
  }
}
