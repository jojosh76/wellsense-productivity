import 'dart:io';

// 1️⃣ Classe Student
class Student {
  final String name;
  final String course;
  final double? score;

  Student(this.name, this.course, this.score);
}

// 2️⃣ Higher Order Function
String processStudent(
    Student student, String Function(double) gradeCalculator) {
  final score = student.score;

  if (score == null || score < 0 || score > 100) {
    return "Invalid";
  } else {
    return gradeCalculator(score);
  }
}

// 3️⃣ Export CSV (Compatible Excel)
void exportToCSV(List<List<String>> results) {
  final file = File('students_results.csv');
  final sink = file.openWrite();

  // Header
  sink.writeln("STUDENT,COURSE,GRADE");

  // Data
  for (var row in results) {
    sink.writeln("${row[0]},${row[1]},${row[2]}");
  }

  sink.close();

  print("\n✅ CSV file generated at: ${file.absolute.path}");
}

void main() {
  final students = <Student>[];

  stdout.write("How many students? ");
  final numberInput = stdin.readLineSync();
  final number = int.tryParse(numberInput ?? "") ?? 0;

  // 4️⃣ Lambda grade calculator
  String Function(double) calculateGrade = (double s) {
    if (s >= 80) return "A";
    if (s >= 70) return "B";
    if (s >= 60) return "C+";
    if (s >= 50) return "C";
    if (s >= 40) return "D";
    return "F";
  };

  // 5️⃣ Input Loop
  for (int i = 0; i < number; i++) {
    print("\n--- Student ${i + 1} ---");

    stdout.write("Name: ");
    final name = stdin.readLineSync();
    final studentName =
        (name == null || name.isEmpty) ? "Unknown" : name;

    stdout.write("Course: ");
    final course = stdin.readLineSync();
    final studentCourse =
        (course == null || course.isEmpty) ? "N/A" : course;

    stdout.write("Score: ");
    final scoreInput =
        stdin.readLineSync()?.replaceAll(',', '.');
    final score = double.tryParse(scoreInput ?? "");

    students.add(Student(studentName, studentCourse, score));
  }

  // 6️⃣ Process Results
  final resultList = students.map((st) {
    final grade = processStudent(st, calculateGrade);
    return [st.name, st.course, grade];
  }).toList();

  // 7️⃣ Console Table
  print("\n========== RESULT TABLE ==========");
  print(
      "${"STUDENT".padRight(15)}${"COURSE".padRight(15)}${"GRADE".padRight(10)}");
  print("---------------------------------------------");

  for (var row in resultList) {
    print(
        "${row[0].padRight(15)}${row[1].padRight(15)}${row[2].padRight(10)}");
  }

  // 8️⃣ Export CSV
  exportToCSV(resultList);
}