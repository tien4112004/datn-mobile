import 'package:datn_mobile/features/classes/ui/widgets/detail/post_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream tab showing posts from teachers with full CRUD functionality
class StreamTab extends ConsumerWidget {
  final String classId;

  const StreamTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PostList now handles its own refresh logic with paging controller
    return PostList(classId: classId);
  }
}
