import 'package:auto_route/annotations.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/home/ui/widgets/today_works_section.dart';
import 'package:datn_mobile/features/home/ui/widgets/my_classes_section.dart';
import 'package:datn_mobile/features/home/ui/widgets/recent_documents_section.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';

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

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            TodayWorksSection(),
            SizedBox(height: 32),
            MyClassesSection(),
            SizedBox(height: 32),
            RecentDocumentsSection(),
            SizedBox(height: 16),
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

        return AppBar(
          title: Text(
            t.homeGreeting,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          actions: [
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
                            Icons.monetization_on,
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
