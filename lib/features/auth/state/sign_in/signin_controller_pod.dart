import 'package:datn_mobile/features/auth/state/auth_state.dart';
import 'package:datn_mobile/features/auth/state/sign_in/signin_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signinControllerProvider =
    AsyncNotifierProvider<SigninController, AuthState>(() {
      return SigninController();
    });
