# Question Bank Filter Architecture

This document describes how the filtering mechanism works in the Question Bank feature.

## Overview

The filtering system allows users to query questions based on various criteria (Bank Type, Search, Grade, Subject, Chapter, Type, Difficulty). It uses `Riverpod` for state management, separating the **Filter State** from the **Question Data State**.

## Core Components

### 1. Filter State (`QuestionBankFilterState`)

Defined in `lib/features/questions/states/question_bank_filter_state.dart`.

It is an immutable `freezed` class that holds the current filter configuration:

```dart
class QuestionBankFilterState {
  final BankType bankType;              // Personal vs Public
  final String? searchQuery;            // Text search
  final GradeLevel? gradeFilter;        // Grade 1-12, etc.
  final Subject? subjectFilter;         // Math, Physics, etc.
  final List<String> chapterFilters;    // Specific chapters
  final QuestionType? questionTypeFilter; // Multiple Choice, Matching, etc.
  final Difficulty? difficultyFilter;   // Easy, Medium, Hard, etc.
}
```

- **`getFilterParams()`**: Converts the state into `QuestionBankFilterParams` which handles logic for API parameter mapping (e.g., taking the first chapter if multiple are selected, though the UI currently supports multi-select in state, the API might strictly use one depending on implementation).
- **`clearFilters()`**: Resets all filters *except* `bankType`.
- **`hasActiveFilters`**: Helper to check if any filter is applied (useful for UI indicators).

### 2. Providers (`QuestionBankProvider`)

Defined in `lib/features/questions/states/question_bank_provider.dart`.

There are two main providers involved:

*   **`questionBankFilterProvider`**: A `StateProvider<QuestionBankFilterState>` that holds the *current* filter configuration. This is the "source of truth" for what the user has selected.
*   **`questionBankProvider`**: An `AsyncNotifierProvider<QuestionBankController, QuestionBankState>` that manages the *list of questions*.

### 3. Controller Logic (`QuestionBankController`)

The controller links the filter state to the API calls.

*   **`loadQuestionsWithFilter()`**:
    1.  Reads the current state from `questionBankFilterProvider`.
    2.  Converts the state into API parameters.
    3.  Calls `QuestionBankRepository.getQuestions(...)`.
    4.  Updates the `questionBankProvider` state with the fetched list.

## Data Flow

1.  **User Interaction**: The user interacts with the UI (switches bank type, types in search bar, selects a chip, or uses the advanced dialog).
2.  **State Update**: The UI component updates the `questionBankFilterProvider`.
    *   *Example:* `ref.read(questionBankFilterProvider.notifier).state = newState;`
3.  **Fetch Trigger**: Immediately after updating the filter state, the UI (or a listener) calls `ref.read(questionBankProvider.notifier).loadQuestionsWithFilter()`.
4.  **API Call**: The controller reads the *new* filter state, fetches data, and updates the UI list.

## UI Components

### 1. Question Bank Header (`QuestionBankHeader`)

Located in `lib/features/questions/ui/widgets/question_bank_header.dart`.

*   **Bank Type Switcher**: Toggles between Personal and Public.
*   **Search Bar**: Updates `searchQuery`. Note: It usually updates state on submission or debounced input, but the current implementation might trigger on submit.
*   **Quick Filters**: Horizontal scrollable list of chips for quick access to common filters (Grade, Subject, etc.).
*   **Advanced Filter Button**: Opens the modal dialog.

### 2. Advanced Filter Dialog (`AdvancedQuestionFilterDialog`)

Located in `lib/features/questions/ui/widgets/advanced_question_filter_dialog.dart`.

Implements a **Draft Pattern** to prevent excessive API calls while configuring multiple filters:

1.  **Initialization**: When opened, it creates a local `draftState` copy of the current `questionBankFilterProvider` state.
2.  **Modification**: User changes filters (Grade, Subject, Chapters) which only update the local `draftState`.
3.  **Apply**: When "Apply Filters" is clicked:
    *   The global `questionBankFilterProvider` is updated with `draftState`.
    *   `loadQuestionsWithFilter()` is called to fetch new data.
4.  **Clear All**: Resets `draftState`, updates global provider, and reloads data immediately.

### 3. Chapter Filter (`ChapterFilterWidget`)

Located in `lib/features/questions/ui/widgets/chapter_filter_widget.dart`.

*   Only active when both **Grade** and **Subject** are selected.
*   Manages its own local selection of chapters until confirmed/passed back to the parent.

## Usage Example (Code Snippet)

```dart
// In a Widget (e.g., Header)
final filterState = ref.watch(questionBankFilterProvider);
final filterNotifier = ref.read(questionBankFilterProvider.notifier);
final controller = ref.read(questionBankProvider.notifier);

// User selects a grade
void onGradeSelected(GradeLevel newGrade) {
  // 1. Update State
  filterNotifier.state = filterState.copyWith(gradeFilter: newGrade);
  
  // 2. Refresh Data
  controller.loadQuestionsWithFilter();
}
```
