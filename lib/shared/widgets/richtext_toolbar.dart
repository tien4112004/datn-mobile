import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class RichTextToolbar extends StatelessWidget {
  final quill.QuillController controller;

  const RichTextToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: quill.QuillSimpleToolbar(controller: controller),
      ),
    );
  }
}
