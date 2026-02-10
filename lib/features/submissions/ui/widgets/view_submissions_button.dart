import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/i18n/strings.g.dart';

class ViewSubmissionsButton extends StatelessWidget {
  final String postId;

  const ViewSubmissionsButton({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () =>
          context.router.push(SubmissionsListRoute(postId: postId)),
      icon: const Icon(LucideIcons.list),
      label: Text(t.submissions.statistics.viewAllSubmissions),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
