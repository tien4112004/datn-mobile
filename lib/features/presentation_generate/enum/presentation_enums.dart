enum PresentationModel {
  fast('Fast model'),
  balanced('Balanced model'),
  accurate('Accurate model');

  const PresentationModel(this.displayName);
  final String displayName;
}

enum PresentationGrade {
  grade1('Grade 1'),
  grade2('Grade 2'),
  grade3('Grade 3'),
  grade4('Grade 4'),
  grade5('Grade 5');

  const PresentationGrade(this.displayName);
  final String displayName;
}

enum PresentationTheme {
  lorems('Lorems'),
  modern('Modern'),
  classic('Classic'),
  minimal('Minimal');

  const PresentationTheme(this.displayName);
  final String displayName;
}