import 'package:datn_mobile/features/students/enum/student_status.dart';

class Student {
  final String id;
  final String userId;
  final String? address;
  final String? parentContactEmail;
  final StudentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? phoneNumber;

  Student({
    required this.id,
    required this.userId,
    this.address,
    this.parentContactEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.phoneNumber,
  });

  /// Returns the full name of the student, combining firstName and lastName.
  /// Falls back to username if no name is available.
  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.isNotEmpty ? parts.join(' ') : username!;
  }

  Student copyWith({
    String? id,
    String? userId,
    String? address,
    String? parentContactEmail,
    StudentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? password,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phoneNumber,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      parentContactEmail: parentContactEmail ?? this.parentContactEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
