enum StudentGender {
  male(label: 'male'),
  female(label: 'female'),
  other(label: 'other');

  final String label;

  const StudentGender({required this.label});

  String getValue() => label;

  @override
  String toString() => label;

  static StudentGender fromValue(String value) {
    for (StudentGender gender in StudentGender.values) {
      if (gender.getValue() == value.toLowerCase()) {
        return gender;
      }
    }
    return StudentGender.other;
  }
}
