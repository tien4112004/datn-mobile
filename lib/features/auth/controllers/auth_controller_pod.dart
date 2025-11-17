import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:datn_mobile/features/auth/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
