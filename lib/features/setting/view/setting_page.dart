import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/setting/view/setting_content_view.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: ref.watch(translationsPod).settingAppBarTitle,
          ),
          body: const SettingContentView(),
        );
      },
    );
  }
}
