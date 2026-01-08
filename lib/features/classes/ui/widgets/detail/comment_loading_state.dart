import 'package:flutter/material.dart';

/// Loading state widget while comments are being fetched
class CommentLoadingState extends StatelessWidget {
  const CommentLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
