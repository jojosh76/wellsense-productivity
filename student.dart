import 'dart:io';

// 1. Modèle de données
class Student {
  final String name;
  final String course;
  final double score1;
  final double score2;

  Student({
    required this.name,
    required this.course,
    required this.score1,
    required this.score2,
  });
}

// 2. Classe Abstraite pour la logique de calcul
abstract class GradeProcessor {
  // Méthode concrète pour calculer la moyenne
  double calculateAverage(double s1, double s2) {
    return (s1 + s2) / 2;
  }

  // Méthode abstraite que les sous-classes doivent implémenter
  String getGrade(double average);

  // Méthode "Template" qui orchestre le processus
  String process(Student student) {
    if (student.score1 < 0 || student.score1 > 100 || 
        student.score2 < 0 || student.score2 > 100) {
      return "Invalide";
    }
    double average = calculateAverage(student.score1, student.score2);
    return getGrade(average);
  }
}

// 3. Implémentation concrète de la logique
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

// 4. Fonction Export (Note: Pour l'Excel en Dart, on utilise d'ordinaire le package 'excel')
// Ici, je simule l'export car les libs Excel ne sont pas natives à Dart SDK
void exportToCSV(List<Map<String, String>> results) {
  final file = File("students_results.csv");
  String csvContent = "STUDENT,COURSE,GRADE\n";
  
  for (var res in results) {
    csvContent += "${res['name']},${res['course']},${res['grade']}\n";
  }
  
  file.writeAsStringSync(csvContent);
  print("\nFichier CSV généré (alternative Excel) : ${file.absolute.path}");
}

// 5. Main Function
void main() {
  final calculator = StudentGradeCalculator();
  final List<Student> students = [];

  stdout.write("Combien d'étudiants ? ");
  int number = int.tryParse(stdin.readLineSync() ?? '0') ?? 0;

  for (int i = 0; i < number; i++) {
    print("\n--- Étudiant ${i + 1} ---");

    stdout.write("Nom : ");
    String name = stdin.readLineSync() ?? "Inconnu";

    stdout.write("Cours : ");
    String course = stdin.readLineSync() ?? "N/A";

    stdout.write("Note 1 : ");
    double s1 = double.tryParse(stdin.readLineSync()?.replaceAll(',', '.') ?? '0') ?? 0;

    stdout.write("Note 2 : ");
    double s2 = double.tryParse(stdin.readLineSync()?.replaceAll(',', '.') ?? '0') ?? 0;

    students.add(Student(name: name, course: course, score1: s1, score2: s2));
  }

  // Traitement des résultats
  List<Map<String, String>> resultList = students.map((st) {
    return {
      "name": st.name,
      "course": st.course,
      "grade": calculator.process(st),
      "avg": calculator.calculateAverage(st.score1, st.score2).toStringAsFixed(2)
    };
  }).toList();

  // Affichage Console
  print("\n========== TABLEAU DES RÉSULTATS ==========");
  print("${'NOM'.padRight(15)} ${'COURS'.padRight(15)} ${'MOY'.padRight(8)} ${'GRADE'}");
  print("-" * 50);

  for (var res in resultList) {
    print("${res['name']?.padRight(15)} ${res['course']?.padRight(15)} ${res['avg']?.padRight(8)} ${res['grade']}");
  }

  exportToCSV(resultList);
}