/// Parse a cell value string in "count:points" format.
/// Mirrors `parseCellValue` from `@aiprimary/core`.
///
/// Example:
///   parseCellValue("3:6.0") → (count: 3, points: 6.0)
///   parseCellValue("0:0")   → (count: 0, points: 0.0)
///   parseCellValue("bad")   → (count: 0, points: 0.0)
({int count, double points}) parseCellValue(String cellValue) {
  final parts = cellValue.split(':');
  return (
    count: int.tryParse(parts[0]) ?? 0,
    points: double.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0.0,
  );
}

/// Serialize count and points into "count:points" format.
String serializeCellValue(int count, double points) => '$count:$points';
