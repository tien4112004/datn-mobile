part of 'controller_provider.dart';

/// Controller for managing context list with search and pagination.
class ContextsController extends AsyncNotifier<ContextListResult> {
  int _currentPage = 1;
  String? _searchQuery;
  List<String>? _subjectFilter;
  bool _isLoadingMore = false;

  @override
  Future<ContextListResult> build() async {
    return _fetchContexts();
  }

  Future<ContextListResult> _fetchContexts() async {
    final repository = ref.read(contextRepositoryProvider);
    return repository.getContexts(
      page: _currentPage,
      pageSize: 20,
      search: _searchQuery,
      subject: _subjectFilter,
    );
  }

  /// Sets the subject filter and refreshes.
  void setSubjectFilter(List<String>? subjects) {
    _subjectFilter = subjects;
  }

  /// Sets the search query and refreshes.
  Future<void> setSearch(String? query) async {
    _searchQuery = query;
    _currentPage = 1;
    _isLoadingMore = false;
    await refresh();
  }

  /// Refreshes the context list.
  Future<void> refresh() async {
    _currentPage = 1;
    _isLoadingMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchContexts);
  }

  /// Loads the next page of contexts.
  Future<void> loadNextPage() async {
    final currentState = state.value;
    if (currentState == null) return;
    if (_isLoadingMore) return;
    if (!currentState.pagination.hasMore) return;

    _isLoadingMore = true;
    try {
      _currentPage++;

      final repository = ref.read(contextRepositoryProvider);
      final nextPage = await repository.getContexts(
        page: _currentPage,
        pageSize: 20,
        search: _searchQuery,
        subject: _subjectFilter,
      );

      state = AsyncData(
        ContextListResult(
          contexts: [...currentState.contexts, ...nextPage.contexts],
          pagination: nextPage.pagination,
        ),
      );
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// Controller for managing cloned contexts within an assignment.
/// These are local copies of contexts that are stored with the assignment.
class AssignmentContextsController extends AsyncNotifier<List<ContextEntity>> {
  AssignmentContextsController({required this.assignmentId});

  final String assignmentId;

  @override
  Future<List<ContextEntity>> build() async {
    return _loadContextsForAssignment();
  }

  Future<List<ContextEntity>> _loadContextsForAssignment() async {
    // Get the assignment details
    final assignmentController = ref.read(
      detailAssignmentControllerProvider(assignmentId).notifier,
    );
    final assignment = await assignmentController.future;

    // Prefer embedded contexts from the assignment response
    if (assignment.contexts.isNotEmpty) {
      return assignment.contexts;
    }

    // Fallback: extract context IDs from questions and fetch separately
    // (backward compatibility for assignments without embedded contexts)
    final contextIds = assignment.questions
        .where((q) => q.contextId != null)
        .map((q) => q.contextId!)
        .toSet()
        .toList();

    if (contextIds.isEmpty) {
      return [];
    }

    // Fetch contexts by IDs
    final repository = ref.read(contextRepositoryProvider);
    return repository.getContextsByIds(contextIds);
  }

  /// Clones a context for use in assignment and returns the cloned entity.
  /// The cloned context gets a new local ID and tracks its source.
  ///
  /// If a context with the same sourceContextId already exists locally,
  /// returns the existing clone to avoid duplicates.
  ContextEntity cloneContext(ContextEntity sourceContext) {
    // Check for existing clone by sourceContextId
    final existing = getBySourceId(sourceContext.id);
    if (existing != null) return existing;

    // Generate a unique local ID for the cloned context
    final localId = _generateLocalId();

    return sourceContext.copyWith(
      id: localId,
      sourceContextId: sourceContext.id,
    );
  }

  /// Finds an existing cloned context by its source context ID.
  /// Returns null if no clone with this source exists.
  ContextEntity? getBySourceId(String sourceContextId) {
    final contexts = state.value;
    if (contexts == null) return null;

    for (final ctx in contexts) {
      if (ctx.sourceContextId == sourceContextId) return ctx;
      // Also match if the context itself has this ID (for directly fetched contexts)
      if (ctx.id == sourceContextId) return ctx;
    }
    return null;
  }

  /// Updates a cloned context's content.
  Future<void> updateContext(ContextEntity updatedContext) async {
    final currentContexts = state.value ?? [];
    final index = currentContexts.indexWhere((c) => c.id == updatedContext.id);

    if (index != -1) {
      final updatedList = [...currentContexts];
      updatedList[index] = updatedContext;
      state = AsyncData(updatedList);
    }
  }

  /// Adds a cloned context to the assignment.
  Future<void> addContext(ContextEntity context) async {
    final currentContexts = state.value ?? [];
    state = AsyncData([...currentContexts, context]);
  }

  /// Removes a context from the assignment.
  ///
  /// Note: This only removes the context from the contexts list.
  /// The caller (typically AssignmentDetailPage) is responsible for also
  /// clearing contextId from all questions that reference this context,
  /// since that requires the DetailAssignmentController.
  Future<void> removeContext(String contextId) async {
    final currentContexts = state.value ?? [];
    state = AsyncData(currentContexts.where((c) => c.id != contextId).toList());
  }

  /// Gets a context by ID from the local list.
  ContextEntity? getContextById(String contextId) {
    final contexts = state.value;
    if (contexts == null) return null;

    for (final ctx in contexts) {
      if (ctx.id == contextId) return ctx;
    }
    return null;
  }

  String _generateLocalId() {
    return 'ctx_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  String _randomSuffix() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecond;
    return String.fromCharCodes(
      List.generate(
        6,
        (i) => chars.codeUnitAt((random + i * 7) % chars.length),
      ),
    );
  }
}
