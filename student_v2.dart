import 'dart:io';

// 1. Classe de données
class Student {
  final String name;
  final String course;
  final double score1;
  final double score2;

  Student(this.name, this.course, this.score1, this.score2);
}

// 2. Logique de calcul (Abstraite)
abstract class GradeProcessor {
  double calculateAverage(double s1, double s2) => (s1 + s2) / 2;
  String getGrade(double average);

  String process(Student student) {
    if (student.score1 < 0 || student.score1 > 100 || 
        student.score2 < 0 || student.score2 > 100) {
      return "Invalide";
    }
    return getGrade(calculateAverage(student.score1, student.score2));
  }
}

// 3. Implémentation du calculateur
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

// --- FONCTIONS DE GESTION CSV ---

// Remplit le fichier source students.csv à partir de la saisie utilisateur
void saveToSourceCSV(List<Student> students, String path) {
  File file = File(path);
  String header = "name;course;score1;score2\n";
  String content = students.map((s) => 
      "${s.name};${s.course};${s.score1};${s.score2}").join("\n");
  
  file.writeAsStringSync(header + content);
  print("\n[OK] Données enregistrées dans $path");
}

// Lit le fichier students.csv pour le traitement
List<Student> readStudentsFromCSV(String path) {
  File file = File(path);
  if (!file.existsSync()) return [];

  List<String> lines = file.readAsLinesSync();
  List<Student> students = [];

  for (int i = 1; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    var parts = lines[i].split(";");
    if (parts.length >= 4) {
      students.add(Student(
        parts[0].trim(),
        parts[1].trim(),
        double.tryParse(parts[2]) ?? 0.0,
        double.tryParse(parts[3]) ?? 0.0,
      ));
    }
  }
  return students;
}

// Exporte les résultats finaux
void exportResultsToCSV(List<Map<String, String>> results) {
  File file = File("students_results.csv");
  String header = "name;course;CA;final exam;avg;grade\n";
  String content = results.map((res) => 
      "${res["name"]};${res["course"]};${res["ca"]};${res["final"]};${res["avg"]};${res["grade"]}").join("\n");
  
  file.writeAsStringSync(header + content);
  print("[OK] Résultats exportés : ${file.absolute.path}");
}

// --- MAIN ---
void main() {
  var calculator = StudentGradeCalculator();
  List<Student> temporaryList = [];

  // PARTIE 1 : SAISIE (Code 1)
  stdout.write("Combien d'étudiants voulez-vous saisir ? ");
  int number = int.tryParse(stdin.readLineSync() ?? "") ?? 0;

  for (int i = 1; i <= number; i++) {
    print("\n--- Saisie Étudiant $i ---");
    stdout.write("Nom : ");
    String name = (stdin.readLineSync() ?? "").trim();
    stdout.write("Cours : ");
    String course = (stdin.readLineSync() ?? "").trim();
    stdout.write("Note CA : ");
    double s1 = double.tryParse((stdin.readLineSync() ?? "").replaceAll(',', '.')) ?? 0.0;
    stdout.write("Note Exam Final : ");
    double s2 = double.tryParse((stdin.readLineSync() ?? "").replaceAll(',', '.')) ?? 0.0;

    temporaryList.add(Student(name.isEmpty ? "Inconnu" : name, course.isEmpty ? "N/A" : course, s1, s2));
  }

  // PARTIE 2 : REMPLISSAGE DU FICHIER (Fusion)
  saveToSourceCSV(temporaryList, "students.csv");

  // PARTIE 3 : LECTURE ET CALCUL (Code 2)
  List<Student> studentsFromFile = readStudentsFromCSV("students.csv");

  var resultList = studentsFromFile.map((st) {
    return {
      "name": st.name,
      "course": st.course,
      "ca": st.score1.toString(),
      "final": st.score2.toString(),
      "avg": calculator.calculateAverage(st.score1, st.score2).toStringAsFixed(2),
      "grade": calculator.process(st)
    };
  }).toList();

  // Affichage Console
  print("\n========== TABLEAU GÉNÉRÉ ==========");
  print("${"NOM".padRight(15)} ${"COURS".padRight(15)} ${"MOY".padRight(8)} GRADE");
  print("-" * 50);

  for (var res in resultList) {
    print("${res["name"]!.padRight(15)} ${res["course"]!.padRight(15)} ${res["avg"]!.padRight(8)} ${res["grade"]}");
  }

  // Export final
  exportResultsToCSV(resultList);
}