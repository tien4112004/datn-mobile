import 'package:datn_mobile/features/auth/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/app/view/app.dart';
import 'package:datn_mobile/bootstrap.dart';
import 'package:datn_mobile/features/splash/view/splash_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Splasher extends ConsumerWidget {
  const Splasher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger get me for init userState
    final _ = ref.watch(userControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: SplashView(
        removeSplashLoader: false,
        onInitialized: (container) {
          bootstrap(() => const App(), parent: container);
        },
      ),
    );
  }
}
