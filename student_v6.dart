import 'dart:io';

// =======================
// 1. Modèles de données (inchangé)
// =======================
class Student {
  final String name;
  final String course;
  final double score1;
  final double score2;
  Student(this.name, this.course, this.score1, this.score2);
}

class StudentResult {
  final String name;
  final String course;
  final double ca;
  final double finalExam;
  final double avg;
  final String grade;
  StudentResult(this.name, this.course, this.ca, this.finalExam, this.avg, this.grade);
}

// =======================
// 2. Logique de calcul (inchangé)
// =======================
abstract class GradeProcessor {
  double calculateAverage(double s1, double s2) => (s1 + s2) / 2;
  String getGrade(double average);
}

class StudentGradeCalculator extends GradeProcessor {
  @override
  String getGrade(double average) {
    if (average >= 80) return "A";
    if (average >= 70) return "B";
    if (average >= 60) return "C+";
    if (average >= 50) return "C";
    if (average >= 40) return "D";
    return "F";
  }
}

// =======================
// 3. Lecture CSV (inchangé)
// =======================
List<Student> readStudentsFromCSV(String path) {
  File file = File(path);
  if (!file.existsSync()) {
    print("\x1B[31mErreur : Fichier '$path' introuvable.\x1B[0m");
    return [];
  }
  try {
    List<String> lines = file.readAsLinesSync();
    List<Student> students = [];
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      var parts = lines[i].split(";");
      if (parts.length >= 4) {
        students.add(Student(
          parts[0].trim(),
          parts[1].trim(),
          double.tryParse(parts[2].replaceAll(',', '.')) ?? 0.0,
          double.tryParse(parts[3].replaceAll(',', '.')) ?? 0.0,
        ));
      }
    }
    return students;
  } catch (e) {
    print("\x1B[31mErreur de lecture : $e\x1B[0m");
    return [];
  }
}

// =======================
// Fonction pour afficher un beau tableau dans le terminal
// =======================
void printBeautifulTable(List<StudentResult> results) {
  print("\n\x1B[1;36m╔══════════════════════════════════════════════════════════════════════════════╗\x1B[0m");
  print("\x1B[1;36m║                          STUDENT RESULTS - PRO                               ║\x1B[0m");
  print("\x1B[1;36m╚══════════════════════════════════════════════════════════════════════════════╝\x1B[0m\n");

  print("Nom            | Cours          | CA   | Examen | Moyenne | Grade");
  print("---------------|----------------|------|--------|---------|-------");

  for (var r in results) {
    String color = (r.grade == "F" || r.grade == "D") ? "\x1B[31m" : "\x1B[32m";
    print("${r.name.padRight(14)} | ${r.course.padRight(14)} | ${r.ca.toStringAsFixed(1).padLeft(4)} | ${r.finalExam.toStringAsFixed(1).padLeft(6)} | ${r.avg.toStringAsFixed(1).padLeft(7)} | $color${r.grade}\x1B[0m");
  }
  print("");
}

// =======================
// Statistiques (comme avant)
// =======================
void displayStats(List<StudentResult> results) {
  Map<String, int> distribution = {};
  for (var r in results) {
    distribution[r.grade] = (distribution[r.grade] ?? 0) + 1;
  }

  print("\x1B[1;33m===== DISTRIBUTION DES GRADES =====\x1B[0m");
  distribution.forEach((grade, count) => print("  $grade : $count"));

  print("\n\x1B[1;33m===== ÉTUDIANTS EN DIFFICULTÉ =====\x1B[0m");
  var atRisk = results.where((r) => r.grade == "F" || r.grade == "D");
  if (atRisk.isEmpty) {
    print("  Aucun étudiant en difficulté.");
  } else {
    for (var s in atRisk) {
      print("  ${s.name} → ${s.grade}");
    }
  }
  print("");
}

// =======================
// Export CSV (inchangé) + Export PDF simplifié (texte beau)
// =======================
void exportResults(List<StudentResult> results) {
  final csvName = "students_results.csv";
  File csvFile = File(csvName);
  String header = "name;course;CA;final_exam;avg;grade\n";
  String content = results.map((r) => "${r.name};${r.course};${r.ca};${r.finalExam};${r.avg};${r.grade}").join("\n");
  csvFile.writeAsStringSync(header + content);
  print("\x1B[32m✅ CSV exporté : $csvName\x1B[0m");

  // Export "PDF" simplifié (fichier texte très lisible que tu peux imprimer en PDF)
  final pdfName = "students_results_report.txt";
  File pdfFile = File(pdfName);
  StringBuffer report = StringBuffer();
  report.writeln("=================================================================");
  report.writeln("                  STUDENT RESULTS REPORT");
  report.writeln("=================================================================\n");
  report.writeln("Date : ${DateTime.now()}");
  report.writeln("Total étudiants : ${results.length}\n");

  report.writeln("Nom            | Cours          | CA   | Examen | Moyenne | Grade");
  report.writeln("---------------|----------------|------|--------|---------|-------");
  for (var r in results) {
    report.writeln("${r.name.padRight(14)} | ${r.course.padRight(14)} | ${r.ca.toStringAsFixed(1).padLeft(4)} | ${r.finalExam.toStringAsFixed(1).padLeft(6)} | ${r.avg.toStringAsFixed(1).padLeft(7)} | ${r.grade}");
  }

  report.writeln("\nDistribution des grades :");
  Map<String, int> dist = {};
  for (var r in results) dist[r.grade] = (dist[r.grade] ?? 0) + 1;
  dist.forEach((g, c) => report.writeln("  $g : $c"));

  pdfFile.writeAsStringSync(report.toString());
  print("\x1B[32m✅ Rapport lisible exporté : $pdfName  (ouvre-le et imprime en PDF)\x1B[0m");
}

// =======================
// Main
// =======================
void main(List<String> args) {
  print("\x1B[1;35m══════════════════════════════════════════════════════════════\x1B[0m");
  print("\x1B[1;35m               STUDENT GRADES PRO - Version Console             \x1B[0m");
  print("\x1B[1;35m══════════════════════════════════════════════════════════════\x1B[0m\n");

  if (args.isEmpty) {
    print("Usage : dart student_grades.dart <fichier.csv>");
    print("Exemple : dart student_grades.dart notes.csv");
    return;
  }

  String filePath = args[0];
  var calculator = StudentGradeCalculator();

  List<Student> students = readStudentsFromCSV(filePath);
  if (students.isEmpty) return;

  List<StudentResult> results = students.map((st) {
    double avg = calculator.calculateAverage(st.score1, st.score2);
    return StudentResult(st.name, st.course, st.score1, st.score2, avg, calculator.getGrade(avg));
  }).toList();

  results.sort((a, b) => b.avg.compareTo(a.avg));

  printBeautifulTable(results);
  displayStats(results);
  exportResults(results);

  print("\x1B[1;32mProgramme terminé avec succès !\x1B[0m");
}