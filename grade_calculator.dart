// Classe Student
class Student {
  final String name;
  final double? score;

  Student(this.name, this.score);
}

// Fonction pour calculer la lettre
String calculateGrade(double? score) {

  // Si score est null
  if (score == null) {
    return "No grade (score is null)";
  }

  if (score >= 90) return "A";
  if (score >= 80) return "B";
  if (score >= 70) return "C";
  if (score >= 60) return "D";
  if (score >= 0) return "F";

  return "Invalid score";
}

void main() {

  // Liste avec cas normaux et null
  final students = [
    Student("Alice", 95.0),
    Student("Bob", 82.5),
    Student("Charlie", 67.0),
    Student("David", null),
  ];

  for (var student in students) {

    final grade = calculateGrade(student.score);

    print(
      "${student.name} -> "
      "Score: ${student.score ?? "Not provided"} -> "
      "Grade: $grade"
    );
  }
}