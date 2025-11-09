import 'package:datn_mobile/features/auth/state/auth_state.dart';
import 'package:datn_mobile/features/auth/state/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  () {
    return AuthController();
  },
);
