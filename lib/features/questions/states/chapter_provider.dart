import 'package:datn_mobile/features/questions/data/dto/chapter_response_dto.dart';
import 'package:datn_mobile/features/questions/data/source/question_bank_remote_source_provider.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to fetch chapters based on grade and subject.
///
/// Returns an empty list if either grade or subject is null.
final chaptersProvider =
    FutureProvider.family<
      List<ChapterResponseDto>,
      ({GradeLevel? grade, Subject? subject})
    >((ref, arg) async {
      final remoteSource = ref.watch(questionBankRemoteSourceProvider);

      if (arg.grade == null || arg.subject == null) {
        return [];
      }

      final response = await remoteSource.getChapters(
        grade: arg.grade!.apiValue,
        subject: arg.subject!.apiValue,
      );

      return response.data ?? [];
    });
