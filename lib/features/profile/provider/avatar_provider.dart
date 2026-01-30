import 'dart:io';
import 'package:AIPrimary/features/profile/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'avatar_state.dart';
part 'avatar_notifier.dart';

final avatarProvider = NotifierProvider<AvatarNotifier, AvatarState>(() {
  return AvatarNotifier();
});
