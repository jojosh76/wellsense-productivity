import 'dart:io';

// 1. Classe équivalente à la Data Class
class Student {
  final String name;
  final String course;
  final double score1;
  final double score2;

  Student(this.name, this.course, this.score1, this.score2);
}

// 2. Classe Abstraite
abstract class GradeProcessor {
  double calculateAverage(double s1, double s2) {
    return (s1 + s2) / 2;
  }

  String getGrade(double average);

  String process(Student student) {
    if (student.score1 < 0 || student.score1 > 100 || 
        student.score2 < 0 || student.score2 > 100) {
      return "Invalide";
    }
    return getGrade(calculateAverage(student.score1, student.score2));
  }
}

// 3. Implémentation
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

// 4. Export CSV
void exportToCSV(List<Map<String, String>> results) {
  File file = File("students_results.csv");
  String header = "STUDENT,COURSE,AVG,GRADE\n";
  String content = results.map((res) => 
      "${res["name"]},${res["course"]},${res["avg"]},${res["grade"]}").join("\n");
  
  file.writeAsStringSync(header + content);
  print("\nFichier CSV généré : ${file.absolute.path}");
}

// 5. MAIN
void main() {
  var calculator = StudentGradeCalculator();
  List<Student> students = [];

  stdout.write("Combien d'étudiants ? ");
  int number = int.tryParse(stdin.readLineSync() ?? "") ?? 0;

  for (int i = 1; i <= number; i++) {
    print("\n--- Étudiant $i ---");
    
    stdout.write("Nom : ");
    String name = (stdin.readLineSync() ?? "").trim();
    if (name.isEmpty) name = "Inconnu";

    stdout.write("Cours : ");
    String course = (stdin.readLineSync() ?? "").trim();
    if (course.isEmpty) course = "N/A";

    stdout.write("CA : ");
    double s1 = double.tryParse((stdin.readLineSync() ?? "").replaceAll(',', '.')) ?? 0.0;

    stdout.write("Final exam : ");
    double s2 = double.tryParse((stdin.readLineSync() ?? "").replaceAll(',', '.')) ?? 0.0;

    students.add(Student(name, course, s1, s2));
  }

  // Affichage invalides
  print("\nÉtudiants avec notes invalides :");
  students.forEach((st) {
    if (st.score1 < 0 || st.score1 > 100 || st.score2 < 0 || st.score2 > 100) {
      print("${st.name} -> Invalide");
    }
  });

  // FILTER
  var validStudents = students.where((st) => 
      st.score1 >= 0 && st.score1 <= 100 && 
      st.score2 >= 0 && st.score2 <= 100).toList();

  // MAP
  var resultList = validStudents.map((st) {
    return {
      "name": st.name,
      "course": st.course,
      "avg": calculator.calculateAverage(st.score1, st.score2).toStringAsFixed(2),
      "grade": calculator.process(st)
    };
  }).toList();

  // Affichage Tableau formaté
  print("\n========== TABLEAU DES RÉSULTATS ==========");
  print("${"NOM".padRight(15)} ${"COURS".padRight(15)} ${"MOY".padRight(8)} GRADE");
  print("-" * 50);

  resultList.forEach((res) {
    print("${res["name"]!.padRight(15)} ${res["course"]!.padRight(15)} ${res["avg"]!.padRight(8)} ${res["grade"]}");
  });

  exportToCSV(resultList);
}