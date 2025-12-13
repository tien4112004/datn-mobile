# Mindmap Generation Flow - Implementation Plan

## Overview

This document outlines the implementation plan for the mindmap generation feature, following the existing presentation generation architecture patterns.

---

## Phase 1: Data Layer (DTOs & Remote Source)

### 1.1 Create DTOs

**Files to create:**
- `lib/features/generate/data/dto/mindmap_generate_request_dto.dart`
- `lib/features/generate/data/dto/mindmap_node_content_dto.dart`

**MindmapGenerateRequestDto** (based on `MindmapGenerateRequest` schema):
```dart
@JsonSerializable()
class MindmapGenerateRequestDto {
  /// The main topic or subject for the mindmap generation
  /// minLength: 1, maxLength: 500
  final String topic;

  /// The AI model to use for generation
  /// enum: gpt-4o, gpt-4-turbo, gpt-3.5-turbo, claude-3-opus, claude-3-sonnet, claude-3-haiku
  final String model;

  /// The AI service provider
  /// enum: openai, anthropic, google
  final String provider;

  /// The language for the mindmap content (ISO 639-1 code)
  /// enum: en, vi, fr, es, de, ja, zh
  final String language;

  /// Maximum depth of the mindmap branches (default 3)
  /// minimum: 1, maximum: 5
  final int? maxDepth;

  /// Maximum number of branches per node (default 5)
  /// minimum: 1, maximum: 10
  final int? maxBranchesPerNode;

  const MindmapGenerateRequestDto({
    required this.topic,
    required this.model,
    required this.provider,
    required this.language,
    this.maxDepth,
    this.maxBranchesPerNode,
  });

  factory MindmapGenerateRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapGenerateRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapGenerateRequestDtoToJson(this);
}
```

**MindmapNodeContentDto** (based on `MindmapNodeContent` & `MindmapGenerateResponse` schema):
```dart
/// A node in the mindmap hierarchy with recursive children structure
/// Used for both request and response
@JsonSerializable()
class MindmapNodeContentDto {
  /// Text content of the node
  final String content;

  /// Child nodes branching from this node
  final List<MindmapNodeContentDto>? children;

  const MindmapNodeContentDto({
    required this.content,
    this.children,
  });

  factory MindmapNodeContentDto.fromJson(Map<String, dynamic> json) =>
      _$MindmapNodeContentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MindmapNodeContentDtoToJson(this);
}
```

> **Note:** `MindmapGenerateResponse` has the same structure as `MindmapNodeContentDto` (content + children), so we can reuse `MindmapNodeContentDto` for the response.

### 1.2 Create Remote Source

**File to create:**
- `lib/features/generate/data/source/mindmap_remote_source.dart`

**Endpoints to implement:**
```dart
@RestApi()
abstract class MindmapRemoteSource {
  factory MindmapRemoteSource(Dio dio, {String baseUrl}) = _MindmapRemoteSource;

  /// POST /mindmaps/generate
  /// Generate a mindmap from a topic using AI
  @POST("/mindmaps/generate")
  Future<ServerResponseDto<MindmapNodeContentDto>> generateMindmap(
    @Body() MindmapGenerateRequestDto request,
  );
}
```

### 1.3 Update Source Provider

**File to update:**
- `lib/features/generate/data/source/source_provider.dart` (or create if not exists)

Add provider for `MindmapRemoteSource`.

---

## Phase 2: Domain Layer (Entities & Repository Interface)

### 2.1 Create Domain Entity

**File to create:**
- `lib/features/generate/domain/entity/mindmap_node_content.dart`

```dart
/// Domain entity representing a node in the generated mindmap
class MindmapNodeContent {
  final String content;
  final List<MindmapNodeContent> children;

  const MindmapNodeContent({
    required this.content,
    this.children = const [],
  });

  /// Convert from DTO
  factory MindmapNodeContent.fromDto(MindmapNodeContentDto dto) {
    return MindmapNodeContent(
      content: dto.content,
      children: dto.children
          ?.map((child) => MindmapNodeContent.fromDto(child))
          .toList() ?? [],
    );
  }

  /// Convert to DTO
  MindmapNodeContentDto toDto() {
    return MindmapNodeContentDto(
      content: content,
      children: children.isEmpty
          ? null
          : children.map((child) => child.toDto()).toList(),
    );
  }
}
```

### 2.2 Create Repository Interface

**File to create:**
- `lib/features/generate/domain/repository/mindmap_repository.dart`

```dart
abstract class MindmapRepository {
  /// Generate a mindmap from a topic
  Future<MindmapNodeContent> generateMindmap(MindmapGenerateRequestDto request);
}
```

---

## Phase 3: Data Layer Implementation (Repository)

### 3.1 Implement Repository

**File to create:**
- `lib/features/generate/data/repository/mindmap_repository_impl.dart`

```dart
class MindmapRepositoryImpl implements MindmapRepository {
  final MindmapRemoteSource _remoteSource;

  MindmapRepositoryImpl(this._remoteSource);

  @override
  Future<MindmapNodeContent> generateMindmap(MindmapGenerateRequestDto request) async {
    final response = await _remoteSource.generateMindmap(request);

    if (response.data == null) {
      throw Exception('Failed to generate mindmap: No data returned');
    }

    return MindmapNodeContent.fromDto(response.data!);
  }
}
```

### 3.2 Update Repository Provider

**File to update:**
- `lib/features/generate/data/repository/repository_provider.dart`

```dart
final mindmapRepositoryProvider = Provider<MindmapRepository>((ref) {
  final remoteSource = ref.watch(mindmapRemoteSourceProvider);
  return MindmapRepositoryImpl(remoteSource);
});
```

---

## Phase 4: Service Layer

### 4.1 Create Service Interface

**File to create:**
- `lib/features/generate/domain/service/mindmap_service.dart`

```dart
abstract class MindmapService {
  /// Generate a mindmap from a topic
  Future<MindmapNodeContent> generateMindmap({
    required String topic,
    required AIModel model,
    required String language,
    int? maxDepth,
    int? maxBranchesPerNode,
  });
}
```

### 4.2 Implement Service

**File to create:**
- `lib/features/generate/service/mindmap_service_impl.dart`

```dart
class MindmapServiceImpl implements MindmapService {
  final MindmapRepository _repository;

  MindmapServiceImpl(this._repository);

  @override
  Future<MindmapNodeContent> generateMindmap({
    required String topic,
    required AIModel model,
    required String language,
    int? maxDepth,
    int? maxBranchesPerNode,
  }) async {
    final request = MindmapGenerateRequestDto(
      topic: topic,
      model: model.name,
      provider: model.provider,
      language: language,
      maxDepth: maxDepth,
      maxBranchesPerNode: maxBranchesPerNode,
    );

    return _repository.generateMindmap(request);
  }
}
```

### 4.3 Update Service Provider

**File to update:**
- `lib/features/generate/service/service_provider.dart`

```dart
final mindmapServiceProvider = Provider<MindmapService>((ref) {
  final repository = ref.watch(mindmapRepositoryProvider);
  return MindmapServiceImpl(repository);
});
```

---

## Phase 5: State Management

### 5.1 Create Form State

**File to create:**
- `lib/features/generate/states/mindmap_form_state.dart`

```dart
class MindmapFormState {
  final String topic;
  final AIModel? selectedModel;
  final String language;
  final int maxDepth;
  final int maxBranchesPerNode;

  const MindmapFormState({
    this.topic = '',
    this.selectedModel,
    this.language = 'en',
    this.maxDepth = 3,
    this.maxBranchesPerNode = 5,
  });

  MindmapFormState copyWith({
    String? topic,
    AIModel? selectedModel,
    String? language,
    int? maxDepth,
    int? maxBranchesPerNode,
  }) {
    return MindmapFormState(
      topic: topic ?? this.topic,
      selectedModel: selectedModel ?? this.selectedModel,
      language: language ?? this.language,
      maxDepth: maxDepth ?? this.maxDepth,
      maxBranchesPerNode: maxBranchesPerNode ?? this.maxBranchesPerNode,
    );
  }

  /// Validate if form is ready for submission
  bool get isValid => topic.isNotEmpty && selectedModel != null;
}
```

### 5.2 Create Generate State

**File to create:**
- `lib/features/generate/states/mindmap_generate_state.dart`

```dart
class MindmapGenerateState {
  final MindmapNodeContent? generatedMindmap;

  const MindmapGenerateState({
    this.generatedMindmap,
  });

  MindmapGenerateState copyWith({
    MindmapNodeContent? generatedMindmap,
  }) {
    return MindmapGenerateState(
      generatedMindmap: generatedMindmap ?? this.generatedMindmap,
    );
  }
}
```

### 5.3 Create Form Controller

**File to create:**
- `lib/features/generate/states/mindmap_form_controller.dart`

```dart
class MindmapFormController extends Notifier<MindmapFormState> {
  @override
  MindmapFormState build() => const MindmapFormState();

  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateMaxDepth(int maxDepth) {
    state = state.copyWith(maxDepth: maxDepth);
  }

  void updateMaxBranchesPerNode(int maxBranchesPerNode) {
    state = state.copyWith(maxBranchesPerNode: maxBranchesPerNode);
  }

  void reset() {
    state = const MindmapFormState();
  }
}
```

### 5.4 Create Generate Controller

**File to create:**
- `lib/features/generate/states/mindmap_generate_controller.dart`

```dart
class MindmapGenerateController extends AsyncNotifier<MindmapGenerateState> {
  @override
  FutureOr<MindmapGenerateState> build() => const MindmapGenerateState();

  Future<void> generateMindmap() async {
    final formState = ref.read(mindmapFormControllerProvider);

    if (!formState.isValid) {
      throw Exception('Invalid form state');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(mindmapServiceProvider);

      final result = await service.generateMindmap(
        topic: formState.topic,
        model: formState.selectedModel!,
        language: formState.language,
        maxDepth: formState.maxDepth,
        maxBranchesPerNode: formState.maxBranchesPerNode,
      );

      return MindmapGenerateState(generatedMindmap: result);
    });
  }

  void reset() {
    state = const AsyncData(MindmapGenerateState());
  }
}
```

### 5.5 Update Controller Provider

**File to update:**
- `lib/features/generate/states/controller_provider.dart`

```dart
final mindmapFormControllerProvider =
    NotifierProvider<MindmapFormController, MindmapFormState>(
  MindmapFormController.new,
);

final mindmapGenerateControllerProvider =
    AsyncNotifierProvider<MindmapGenerateController, MindmapGenerateState>(
  MindmapGenerateController.new,
);
```

---

## Phase 6: UI Layer

### 6.1 Create Mindmap Generate Page

**File to create:**
- `lib/features/generate/ui/pages/mindmap_generate_page.dart`

**Features:**
- Topic input field (maxLength: 500)
- Language selector (en, vi, fr, es, de, ja, zh)
- AI model selector (reuse existing `ModelsController`)
- Max depth slider (1-5, default 3)
- Max branches per node slider (1-10, default 5)
- Generate button
- Loading state handling

### 6.2 Create Mindmap Result Page

**File to create:**
- `lib/features/generate/ui/pages/mindmap_result_page.dart`

**Features:**
- Display generated mindmap structure (tree view)
- Show root content and all children recursively
- Save to server option (POST /mindmaps)
- Navigate to mindmap editor option

### 6.3 Update Generator Type Handling

**File to update:**
- Update the existing page that shows "Coming soon" to navigate to the new mindmap page

---

## Phase 7: Integration & Navigation

### 7.1 Update Routes

- Add route for `MindmapGeneratePage`
- Add route for `MindmapResultPage`

### 7.2 Update Generator Type Selection

- Remove "Coming soon" message for mindmap
- Navigate to `MindmapGeneratePage` when mindmap is selected

---

## File Structure Summary

```
lib/features/generate/
├── data/
│   ├── dto/
│   │   ├── mindmap_generate_request_dto.dart     [NEW]
│   │   └── mindmap_node_content_dto.dart         [NEW]
│   ├── repository/
│   │   ├── mindmap_repository_impl.dart          [NEW]
│   │   └── repository_provider.dart              [UPDATE]
│   └── source/
│       └── mindmap_remote_source.dart            [NEW]
├── domain/
│   ├── entity/
│   │   └── mindmap_node_content.dart             [NEW]
│   ├── repository/
│   │   └── mindmap_repository.dart               [NEW]
│   └── service/
│       └── mindmap_service.dart                  [NEW]
├── service/
│   ├── mindmap_service_impl.dart                 [NEW]
│   └── service_provider.dart                     [UPDATE]
├── states/
|   ├── controller_provider.dart                  [UPDATE]
│   └── mindmap/
│       ├── mindmap_form_state.dart                   [NEW]
│       ├── mindmap_form_controller.dart              [NEW]
│       ├── mindmap_generate_state.dart               [NEW]
│       ├── mindmap_generate_controller.dart          [NEW]
└── ui/
    └── pages/
        ├── mindmap_generate_page.dart            [NEW]
        └── mindmap_result_page.dart              [NEW]
```

---

## Implementation Order

### Recommended sequence:

1. **Phase 1**: DTOs & Remote Source (foundation for API communication)
2. **Phase 2**: Domain entities & repository interface
3. **Phase 3**: Repository implementation
4. **Phase 4**: Service layer
5. **Phase 5**: State management (controllers & states)
6. **Phase 6**: UI layer (pages)
7. **Phase 7**: Integration & navigation

---

## API Schema Reference

### Request Schema (MindmapGenerateRequest)
| Field | Type | Required | Constraints | Default |
|-------|------|----------|-------------|---------|
| topic | string | Yes | minLength: 1, maxLength: 500 | - |
| model | string | Yes | enum: gpt-4o, gpt-4-turbo, gpt-3.5-turbo, claude-3-opus, claude-3-sonnet, claude-3-haiku | - |
| provider | string | Yes | enum: openai, anthropic, google | - |
| language | string | Yes | enum: en, vi, fr, es, de, ja, zh | - |
| maxDepth | integer | No | min: 1, max: 5 | 3 |
| maxBranchesPerNode | integer | No | min: 1, max: 10 | 5 |

### Response Schema (MindmapGenerateResponse)
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| content | string | Yes | The central concept or root content |
| children | MindmapNodeContent[] | No | Array of main branches as child nodes |

### MindmapNodeContent Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| content | string | Yes | Text content of the node |
| children | MindmapNodeContent[] | No | Child nodes (recursive) |

---

## Dependencies

- Existing `AIModel` entity and `ModelsController` for model selection
- Existing `ServerResponseDto` for API response wrapping
- Existing Dio instance for HTTP requests
- Riverpod for state management
- Error handling via `default_api_error_handler.dart` (already handles 4xx errors)

---

## Notes

1. **Reuse existing components:**
   - AI model selection UI and controller
   - Language selector
   - Common styling and widgets

2. **Follow existing patterns:**
   - Use `AsyncNotifier` for async operations
   - Use `Notifier` for form state
   - Use Retrofit for API calls
   - Use `JsonSerializable` for DTOs

3. **Naming convention:**
   - Using `MindmapNodeContent` instead of `MindmapNode` to differentiate from the complex node types (MindmapTextNode, MindmapRootNode, etc.) defined in schemas.yaml
   - The generate endpoint returns a simplified tree structure, not the full node types
