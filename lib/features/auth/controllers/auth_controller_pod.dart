import 'package:AIPrimary/features/auth/controllers/auth_state.dart';
import 'package:AIPrimary/features/auth/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerPod = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
