import 'package:flutter/material.dart';

enum StudentStatus {
  active(label: 'active', color: Color(0xFF4CAF50)),
  transferred(label: 'transferred', color: Color(0xFF2196F3)),
  graduated(label: 'graduated', color: Color(0xFF9C27B0)),
  dropped(label: 'dropped', color: Color(0xFFF44336));

  final String label;
  final Color color;

  const StudentStatus({required this.label, required this.color});

  String getValue() => label;

  @override
  String toString() => label;

  static StudentStatus fromValue(String value) {
    for (StudentStatus status in StudentStatus.values) {
      if (status.getValue() == value) {
        return status;
      }
    }
    throw ArgumentError("Invalid StudentStatus value: $value");
  }
}
