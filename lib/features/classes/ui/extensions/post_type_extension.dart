import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

extension PostTypeUIExtension on PostType {
  IconData get icon {
    switch (this) {
      case PostType.post:
        return LucideIcons.messageCircle;
      case PostType.exercise:
        return LucideIcons.clipboardList;
    }
  }
}
