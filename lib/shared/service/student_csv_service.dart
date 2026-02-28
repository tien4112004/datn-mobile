import 'dart:io';

import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:AIPrimary/shared/services/download_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Service for CSV import/export operations on student data.
///
/// Depends on [DownloadService] for saving files to the device's Downloads
/// folder consistently with the rest of the app.
class StudentCsvService {
  final DownloadService _downloadService;

  StudentCsvService(this._downloadService);

  static const _templateAssetPath =
      'assets/templates/student-import-template.csv';

  static const _csvHeaders = [
    'fullName',
    'dateOfBirth',
    'gender',
    'address',
    'parentName',
    'parentPhone',
    'parentContactEmail',
  ];

  // ── file picking ──────────────────────────────────────────────────────────

  /// Launches the system file picker and returns the selected CSV [File].
  /// Returns `null` if the user cancels.
  Future<File?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    return File(path);
  }

  // ── save to device (Downloads folder) ────────────────────────────────────

  /// Generates a CSV from [students], saves it to the Downloads folder via
  /// [DownloadService], and returns the saved file path.
  Future<String> exportStudentsToCsv(
    List<Student> students, {
    String? fileName,
  }) async {
    final exportFileName =
        fileName ??
        'students_export_${DateTime.now().millisecondsSinceEpoch}.csv';

    return _downloadService.saveTextFile(
      fileName: exportFileName,
      content: _buildCsvContent(students),
    );
  }

  /// Copies the bundled CSV template to the Downloads folder and returns its path.
  Future<String> saveTemplate() async {
    return _downloadService.saveTextFile(
      fileName: 'student-import-template.csv',
      content: await _templateContent(),
    );
  }

  // ── save to temp (for sharing) ────────────────────────────────────────────

  /// Generates a CSV from [students], saves it to a temp file, and returns the
  /// path so the caller can share it via [ShareService].
  Future<String> exportStudentsToCsvTemp(
    List<Student> students, {
    String? fileName,
  }) async {
    final exportFileName =
        fileName ??
        'students_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    return _saveToTemp(exportFileName, _buildCsvContent(students));
  }

  /// Copies the bundled CSV template to a temp file and returns its path.
  Future<String> saveTemplateToTemp() async {
    return _saveToTemp('student-import-template.csv', await _templateContent());
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  String _buildCsvContent(List<Student> students) {
    final buffer = StringBuffer();
    buffer.writeln(_csvHeaders.join(','));
    for (final student in students) {
      final row = [
        _escapeCsvField(student.fullName),
        '', // dateOfBirth – not returned by the current API
        '', // gender      – not returned by the current API
        _escapeCsvField(student.address ?? ''),
        '', // parentName  – not returned by the current API
        '', // parentPhone – not returned by the current API
        _escapeCsvField(student.parentContactEmail ?? ''),
      ];
      buffer.writeln(row.join(','));
    }
    return buffer.toString();
  }

  Future<String> _templateContent() async {
    final byteData = await rootBundle.load(_templateAssetPath);
    return String.fromCharCodes(byteData.buffer.asUint8List());
  }

  Future<String> _saveToTemp(String fileName, String content) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  String _escapeCsvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
