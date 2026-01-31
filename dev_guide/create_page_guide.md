<!-- CLAUDE CODE -->

# Create Page Guide

This guide walks you through creating a new page/feature in this Flutter project following the established Feature-First architecture with Riverpod state management.

## Overview

This project follows a Feature-First architecture where each feature is self-contained with its own:
- **UI Layer**: Pages and widgets
- **Controller Layer**: Business logic and state management
- **Data Layer**: DTOs, entities, repositories, and data sources
- **Domain Layer**: Entities and business objects
- **Service Layer**: Business logic services

## Step-by-Step Guide

### 1. Create Feature Directory Structure

Create the following directory structure in `lib/features/`:

```
lib/features/your_feature/
├── controllers/                 # State management and business logic
├── data/                       # Data layer
│   ├── dto/                    # Data Transfer Objects
│   └── source/                 # Remote/Local data sources
├── domain/                     # Domain entities
│   └── entity/
├── service/                    # Business logic services
├── ui/                         # User Interface
│   ├── pages/                  # Page widgets
│   └── widgets/                # Feature-specific widgets
└── enum/                       # Enumerations (if needed)
```

### 2. Create the Page

#### 2.1 Create the Page File
Create `lib/features/your_feature/ui/pages/your_feature_page.dart`:

```dart
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your controllers and widgets here

@RoutePage()
class YourFeaturePage extends StatelessWidget {
  const YourFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Feature')),
      body: const _YourFeatureView(),
    );
  }
}

class _YourFeatureView extends StatelessWidget {
  const _YourFeatureView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your UI components here
          _YourFeatureContent(),
        ],
      ),
    );
  }
}

class _YourFeatureContent extends ConsumerWidget {
  const _YourFeatureContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch your controller here
    final featureAsync = ref.watch(yourFeatureControllerProvider);

    return featureAsync.when(
      data: (data) => Column(
        children: [
          // Display your data here
          Text('Data: $data'),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. Create Domain Entities

#### 3.1 Create Entity
Create `lib/features/your_feature/domain/entity/your_entity.dart`:

```dart
class YourEntity {
  final String? id;
  final String? title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  YourEntity({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  YourEntity copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return YourEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### 4. Create Data Layer

#### 4.1 Create DTO
Create `lib/features/your_feature/data/dto/your_entity_dto.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:AIPrimary/features/your_feature/domain/entity/your_entity.dart';

part 'your_entity_dto.g.dart';

@JsonSerializable()
class YourEntityDto {
  String? id;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;

  YourEntityDto({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory YourEntityDto.fromJson(Map<String, dynamic> json) =>
      _$YourEntityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$YourEntityDtoToJson(this);
}

// Mappers
extension YourEntityMapper on YourEntityDto {
  YourEntity toEntity() {
    return YourEntity(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension YourEntityDtoMapper on YourEntity {
  YourEntityDto toDto() {
    return YourEntityDto(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

#### 4.2 Create Data Source
Create `lib/features/your_feature/data/source/your_feature_remote_source.dart`:

```dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:AIPrimary/features/your_feature/data/dto/your_entity_dto.dart';

part 'your_feature_remote_source.g.dart';

@RestApi()
abstract class YourFeatureRemoteSource {
  factory YourFeatureRemoteSource(Dio dio) = _YourFeatureRemoteSource;

  @GET('/api/your-endpoint')
  Future<List<YourEntityDto>> fetchItems();

  @POST('/api/your-endpoint')
  Future<YourEntityDto> createItem(@Body() YourEntityDto item);

  @PUT('/api/your-endpoint/{id}')
  Future<YourEntityDto> updateItem(@Path() String id, @Body() YourEntityDto item);

  @DELETE('/api/your-endpoint/{id}')
  Future<void> deleteItem(@Path() String id);
}
```

#### 4.3 Create Data Source Provider
Create `lib/features/your_feature/data/source/your_feature_remote_source_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'your_feature_remote_source.dart';

final yourFeatureRemoteSourceProvider = Provider<YourFeatureRemoteSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return YourFeatureRemoteSource(dio);
});
```

### 5. Create Service Layer

#### 5.1 Create Service
Create `lib/features/your_feature/service/your_feature_service.dart`:

```dart
import 'package:AIPrimary/features/your_feature/domain/entity/your_entity.dart';
import 'package:AIPrimary/features/your_feature/data/source/your_feature_remote_source.dart';

class YourFeatureService {
  final YourFeatureRemoteSource _remoteSource;

  YourFeatureService(this._remoteSource);

  Future<List<YourEntity>> fetchItems() async {
    try {
      final dtos = await _remoteSource.fetchItems();
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<YourEntity> createItem(YourEntity item) async {
    try {
      final dto = await _remoteSource.createItem(item.toDto());
      return dto.toEntity();
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  Future<YourEntity> updateItem(String id, YourEntity item) async {
    try {
      final dto = await _remoteSource.updateItem(id, item.toDto());
      return dto.toEntity();
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _remoteSource.deleteItem(id);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }
}
```

#### 5.2 Create Service Provider
Create `lib/features/your_feature/service/service_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/your_feature/data/source/your_feature_remote_source_provider.dart';
import 'your_feature_service.dart';

final yourFeatureServiceProvider = Provider<YourFeatureService>((ref) {
  final remoteSource = ref.watch(yourFeatureRemoteSourceProvider);
  return YourFeatureService(remoteSource);
});
```

### 6. Create Controllers

#### 6.1 Create Controller
Create `lib/features/your_feature/controllers/your_feature_controller.dart`:

```dart
part of 'controller_provider.dart';

// Query Controller - for fetching data
class YourFeatureController extends AsyncNotifier<List<YourEntity>> {
  @override
  Future<List<YourEntity>> build() async {
    final response = await ref
        .read(yourFeatureServiceProvider)
        .fetchItems();
    return response;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final response = await ref
        .read(yourFeatureServiceProvider)
        .fetchItems();
    state = await AsyncValue.guard(() => Future.value(response));
  }
}

// Command Controller - for mutations
class CreateYourEntityController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create(YourEntity entity) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(yourFeatureServiceProvider).createItem(entity);
      await ref.read(yourFeatureControllerProvider.notifier).refresh();
    });
  }
}
```

#### 6.2 Create Controller Provider
Create `lib/features/your_feature/controllers/controller_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/your_feature/domain/entity/your_entity.dart';
import 'package:AIPrimary/features/your_feature/service/service_provider.dart';

part 'your_feature_controller.dart';

final yourFeatureControllerProvider =
    AsyncNotifierProvider<YourFeatureController, List<YourEntity>>(
  () => YourFeatureController(),
);

final createYourEntityControllerProvider =
    AsyncNotifierProvider<CreateYourEntityController, void>(
  () => CreateYourEntityController(),
);
```

### 7. Add Route Configuration

#### 7.1 Update Router
Add your route to `lib/core/router/router.dart`:

```dart
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  late final List<AutoRoute> routes = [
    // Existing routes...
    AutoRoute(page: YourFeatureRoute.page, path: '/your-feature'),
    // ... other routes
  ];
}
```

### 8. Generate Code

Run the following commands to generate the required code:

```bash
# Generate code for auto_route, json_serializable, etc.
flutter packages pub run build_runner build --delete-conflicting-outputs

# Generate translations (if you added new translation keys)
flutter packages pub run slang
```

### 9. Common Patterns

#### 9.1 Using AsyncValue.when()
For handling loading, error, and success states:

```dart
asyncValue.when(
  data: (data) => YourSuccessWidget(data: data),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => YourErrorWidget(error: error),
)
```

#### 9.2 Using easyWhen() Extension
This project includes a custom extension for easier AsyncValue handling:

```dart
asyncValue.easyWhen(
  data: (data) => YourSuccessWidget(data: data),
)
```

#### 9.3 Refresh Pattern
For implementing pull-to-refresh:

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(yourControllerProvider.notifier).refresh();
  },
  child: YourListWidget(),
)
```

## Best Practices

### 1. File Naming Convention
- Pages: `your_feature_page.dart`
- Controllers: `your_feature_controller.dart`
- DTOs: `your_entity_dto.dart`
- Entities: `your_entity.dart`
- Services: `your_feature_service.dart`

### 2. State Management
- Use `AsyncNotifier` for data fetching (queries)
- Separate read operations from write operations
- Use separate controllers for commands (create, update, delete)

### 3. Error Handling
- Handle errors in the service layer
- Use AsyncValue for automatic error state management
- Provide meaningful error messages to users

### 4. Code Organization
- Keep pages simple - delegate logic to controllers
- Use private widgets (prefixed with `_`) for page-specific components
- Extract reusable widgets to the feature's widgets directory

### 5. Testing
Create corresponding test files:
- `test/features/your_feature/ui/pages/your_feature_page_test.dart`
- `test/features/your_feature/controllers/your_feature_controller_test.dart`
- `test/features/your_feature/service/your_feature_service_test.dart`

## Example: Complete Minimal Page

Here's a complete minimal example for a "Tasks" feature:

```dart
// lib/features/tasks/ui/pages/tasks_page.dart
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/tasks/controllers/controller_provider.dart';

@RoutePage()
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const _TasksList(),
    );
  }
}

class _TasksList extends ConsumerWidget {
  const _TasksList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksControllerProvider);

    return tasksAsync.when(
      data: (tasks) => ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task.title ?? 'Untitled'),
            subtitle: Text(task.createdAt?.toString() ?? ''),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
```

This guide should help you create consistent, well-structured pages following the project's architecture patterns!