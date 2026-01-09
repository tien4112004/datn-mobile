import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

extension PostTypeUIExtension on PostType {
  IconData get icon {
    switch (this) {
      case PostType.general:
        return LucideIcons.messageCircle;
      case PostType.announcement:
        return LucideIcons.megaphone;
      case PostType.scheduleEvent:
        return LucideIcons.calendar;
    }
  }

  String get createPageLabel {
    switch (this) {
      case PostType.general:
        return 'General Post';
      case PostType.announcement:
        return 'Announcement';
      case PostType.scheduleEvent:
        return 'Event';
    }
  }
}
