import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final pagingControllerPod =
    Provider.autoDispose<PagingController<int, PresentationMinimal>>((ref) {
      late final pagingController = PagingController<int, PresentationMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) => ref
            .read(presentationServiceProvider)
            .fetchPresentationMinimalsPaged(pageKey),
      );
      return pagingController;
    });

final imagePagingControllerPod =
    Provider.autoDispose<PagingController<int, ImageProjectMinimal>>((ref) {
      late final pagingController = PagingController<int, ImageProjectMinimal>(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) {
            return null;
          }
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) =>
            ref.read(imageServiceProvider).fetchImageMinimalsPaged(pageKey),
      );
      return pagingController;
    });
