import 'package:datn_mobile/features/classes/ui/widgets/detail/post_list.dart';
import 'package:flutter/material.dart';

/// Stream tab showing posts from teachers with full CRUD functionality
class StreamTab extends StatelessWidget {
  final String classId;

  const StreamTab({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return PostList(classId: classId);
  }
}
