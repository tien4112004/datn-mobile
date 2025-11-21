part of 'repository_provider.dart';

class MockPresentationRepositoryImpl implements PresentationRepository {
  final List<Presentation> _presentations = [];

  MockPresentationRepositoryImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();

    // Add sample presentations
    _presentations.addAll([
      Presentation(
        id: '1',
        title: 'Introduction to Flutter',
        slides: [
          _createSlide('1-1', 'Welcome to Flutter', '#4285F4'),
          _createSlide('1-2', 'What is Flutter?', '#34A853'),
          _createSlide('1-3', 'Getting Started', '#FBBC05'),
        ],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 2)),
        isParsed: true,
        metaData: {},
        deletedAt: DateTime(0),
        viewport: {'width': 1000, 'height': 562.5},
      ),
      Presentation(
        id: '2',
        title: 'Advanced Dart Programming',
        slides: [
          _createSlide('2-1', 'Async Programming', '#EA4335'),
          _createSlide('2-2', 'Futures and Streams', '#4285F4'),
        ],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        isParsed: true,
        metaData: {},
        deletedAt: DateTime(0),
        viewport: {'width': 1000, 'height': 562.5},
      ),
      Presentation(
        id: '3',
        title: 'State Management in Flutter',
        slides: [
          _createSlide('3-1', 'Provider Pattern', '#34A853'),
          _createSlide('3-2', 'Riverpod Basics', '#FBBC05'),
          _createSlide('3-3', 'State Management Best Practices', '#EA4335'),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        isParsed: true,
        metaData: {},
        deletedAt: DateTime(0),
        viewport: {'width': 1000, 'height': 562.5},
      ),
    ]);
  }

  Slide _createSlide(String id, String content, String backgroundColor) {
    return Slide(
      id: id,
      elements: [
        SlideElement(
          type: SlideElementType.text,
          id: '$id-text-1',
          left: 100.0,
          top: 200.0,
          width: 600.0,
          height: 200.0,
          viewBox: [],
          path: '',
          fill: '#000000',
          fixedRatio: false,
          opacity: 1.0,
          rotate: 0.0,
          flipV: false,
          lineHeight: 1.5,
          content: content,
          defaultFontName: 'Arial',
          defaultColor: '#000000',
          start: [],
          end: [],
          points: [],
          color: '#000000',
          style: 'normal',
          wordSpace: 0.0,
        ),
      ],
      background: SlideBackground(type: 'solid', color: backgroundColor),
    );
  }

  @override
  Future<void> addPresentation(Presentation presentation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _presentations.add(presentation);
  }

  @override
  Future<List<PresentationMinimal>> fetchPresentations() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return _presentations.map((presentation) {
      return PresentationMinimal(
        id: presentation.id,
        title: presentation.title,
        createdAt: presentation.createdAt,
        updatedAt: presentation.updatedAt,
        thumbnail: presentation.slides.isNotEmpty
            ? presentation.slides.first
            : null,
      );
    }).toList();
  }

  @override
  Future<Presentation> fetchPresentationById(String id) {
    // Simulate network delay
    return Future.delayed(const Duration(milliseconds: 800), () {
      final presentation = _presentations.firstWhere(
        (presentation) => presentation.id == id,
      );
      return presentation;
    });
  }
}
