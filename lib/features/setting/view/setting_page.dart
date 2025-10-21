import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/setting/view/setting_content_view.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const SettingAppBarTitle()),
      body: const SettingContentView(),
    );
  }
}

class SettingAppBarTitle extends ConsumerWidget {
  const SettingAppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Text(t.settingAppBarTitle);
  }
}
