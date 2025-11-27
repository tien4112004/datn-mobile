import 'package:datn_mobile/features/projects/data/source/projects_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projectsRemoteSourceProvider = Provider<ProjectsRemoteSource>((ref) {
  return ProjectsRemoteSource(ref.read(dioPod));
});
