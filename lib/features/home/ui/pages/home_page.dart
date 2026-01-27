import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/notification/ui/widgets/notification_bell.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/home/ui/widgets/today_works_section.dart';
import 'package:datn_mobile/features/home/ui/widgets/my_classes_section.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/recent_documents_row.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _HomeAppBar(),
      body: SafeArea(child: _HomeView()),
    );
  }
}

class _HomeView extends ConsumerWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const TodayWorksSection(),
            const SizedBox(height: 32),
            const MyClassesSection(),
            const SizedBox(height: 32),
            RecentDocumentsRow(title: t.recentDocuments),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final t = ref.watch(translationsPod);

        return CustomAppBar(
          title: t.homeGreeting,
          actions: [
            NotificationBell(
              onTap: () {
                context.router.push(const NotificationListRoute());
              },
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: Themes.boxRadius,
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to credits/purchase page
                      debugPrint('Credits tapped');
                    },
                    borderRadius: Themes.boxRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.coins,
                            size: 20,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '1,250 credits', // TODO: Replace with actual user credits
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
