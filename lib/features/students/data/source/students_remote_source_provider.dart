import 'package:datn_mobile/features/students/data/source/students_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentsRemoteSourceProvider = Provider<StudentsRemoteSource>((ref) {
  final dio = ref.read(dioPod);
  return StudentsRemoteSource(dio);
});
