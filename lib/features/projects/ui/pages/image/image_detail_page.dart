import 'package:auto_route/auto_route.dart';
// import 'package:datn_mobile/features/projects/states/controller_provider.dart';
// import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
// import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ImageDetailPage extends ConsumerWidget {
  final String imageId;

  const ImageDetailPage({
    super.key,
    @PathParam('imageId') required this.imageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.construction, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Image Detail Page is under construction',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );

    // final imageAsync = ref.watch(imageByIdProvider(imageId));

    // return imageAsync.easyWhen(
    //   data: (image) => Scaffold(
    //     appBar: CustomAppBar(
    //       leading: IconButton(
    //         icon: const Icon(LucideIcons.chevronLeft),
    //         onPressed: () => context.router.maybePop(),
    //       ),
    //       title: image.title,
    //     ),
    //     body: SingleChildScrollView(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           // Image display area
    //           Container(
    //             width: double.infinity,
    //             height: 400,
    //             color: Colors.grey.shade200,
    //             child: Center(
    //               child: Icon(
    //                 LucideIcons.image,
    //                 size: 100,
    //                 color: Colors.grey.shade400,
    //               ),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.all(16.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   image.title,
    //                   style: const TextStyle(
    //                     fontSize: 24,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 16),
    //                 if (image.description != null) ...[
    //                   const Text(
    //                     'Description',
    //                     style: TextStyle(
    //                       fontSize: 16,
    //                       fontWeight: FontWeight.w600,
    //                     ),
    //                   ),
    //                   const SizedBox(height: 8),
    //                   Text(
    //                     image.description ?? '',
    //                     style: const TextStyle(fontSize: 14),
    //                   ),
    //                   const SizedBox(height: 16),
    //                 ],
    //                 const Divider(),
    //                 const SizedBox(height: 16),
    //                 Text(
    //                   'Created: ${image.createdAt.toString()}',
    //                   style: TextStyle(
    //                     fontSize: 12,
    //                     color: Colors.grey.shade600,
    //                   ),
    //                 ),
    //                 const SizedBox(height: 8),
    //                 Text(
    //                   'Updated: ${image.updatedAt.toString()}',
    //                   style: TextStyle(
    //                     fontSize: 12,
    //                     color: Colors.grey.shade600,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    //   errorWidget: (error, stackTrace) => Scaffold(
    //     appBar: AppBar(
    //       leading: IconButton(
    //         icon: const Icon(LucideIcons.chevronLeft),
    //         onPressed: () => context.router.maybePop(),
    //       ),
    //     ),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(LucideIcons.info, size: 64, color: Colors.red.shade400),
    //           const SizedBox(height: 16),
    //           Text(
    //             'Error loading image',
    //             style: TextStyle(fontSize: 18, color: Colors.red.shade600),
    //           ),
    //           const SizedBox(height: 16),
    //           ElevatedButton(
    //             onPressed: () => ref.invalidate(imageByIdProvider(imageId)),
    //             child: const Text('Retry'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    //   loadingWidget: () => Scaffold(
    //     appBar: AppBar(
    //       leading: IconButton(
    //         icon: const Icon(LucideIcons.chevronLeft),
    //         onPressed: () => context.router.maybePop(),
    //       ),
    //     ),
    //     body: const Center(child: CircularProgressIndicator()),
    //   ),
    // );
  }
}
