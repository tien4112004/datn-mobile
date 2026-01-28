import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:flutter/material.dart';

class Thumbnail extends StatelessWidget {
  const Thumbnail({super.key, required this.imageUrl});

  // Mock url
  // final String imageUrl;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.network(imageUrl, fit: BoxFit.fitWidth),
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
