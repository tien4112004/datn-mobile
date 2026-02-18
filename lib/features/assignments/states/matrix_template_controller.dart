part of 'controller_provider.dart';

/// Controller for managing matrix template list with search, pagination, and bank type switching.
///
/// Features:
/// - Personal/Public bank type switching
/// - Search with query string
/// - Infinite scroll with cumulative pagination
/// - Grade and subject filtering
class MatrixTemplateController extends AsyncNotifier<MatrixTemplateListResult> {
  int _currentPage = 1;
  String? _searchQuery;
  String _bankType = 'personal'; // Default to personal templates
  String? _filterGrade;
  String? _filterSubject;
  bool _isLoadingMore = false;

  @override
  Future<MatrixTemplateListResult> build() async {
    return _fetchTemplates();
  }

  Future<MatrixTemplateListResult> _fetchTemplates() async {
    final repository = ref.read(matrixTemplateRepositoryProvider);
    return repository.getMatrixTemplates(
      bankType: _bankType,
      page: _currentPage,
      pageSize: 10,
      search: _searchQuery,
      subject: _filterSubject,
      grade: _filterGrade,
    );
  }

  /// Sets filter parameters for grade and subject.
  /// Call this before fetching to filter templates by assignment context.
  void setFilters({String? grade, String? subject}) {
    _filterGrade = grade;
    _filterSubject = subject;
  }

  /// Sets the search query and refreshes from page 1.
  /// Pass null or empty string to clear search.
  Future<void> setSearch(String? query) async {
    _searchQuery = query;
    _currentPage = 1;
    await refresh();
  }

  /// Switches between personal and public template banks.
  /// Resets to page 1 and refetches data.
  Future<void> setBankType(String bankType) async {
    if (_bankType == bankType) return;
    _bankType = bankType;
    _currentPage = 1;
    await refresh();
  }

  /// Refreshes the template list from page 1.
  /// Shows loading state during fetch.
  Future<void> refresh() async {
    _currentPage = 1;
    _isLoadingMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTemplates);
  }

  /// Loads the next page of templates with cumulative append pattern.
  /// This method appends new templates to the existing list for infinite scroll.
  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null) return;
    if (_isLoadingMore) return;
    if (!currentState.pagination.hasMore) return;

    _isLoadingMore = true;
    try {
      _currentPage++;

      final repository = ref.read(matrixTemplateRepositoryProvider);
      final nextPage = await repository.getMatrixTemplates(
        bankType: _bankType,
        page: _currentPage,
        pageSize: 10,
        search: _searchQuery,
        subject: _filterSubject,
        grade: _filterGrade,
      );

      state = AsyncData(
        MatrixTemplateListResult(
          templates: [...currentState.templates, ...nextPage.templates],
          pagination: nextPage.pagination,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }
}
