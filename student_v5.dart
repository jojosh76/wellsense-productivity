import 'dart:io';

// =======================
// 1. Modèles de données
// =======================

// La classe Student représente un étudiant.
// C'est un exemple d'ENCAPSULATION :
// les données (name, course, score1, score2) sont regroupées dans un objet.

class Student {
  final String name;
  final String course;
  final double score1;
  final double score2;

  // Constructeur de la classe
  Student(this.name, this.course, this.score1, this.score2);
}


// Classe qui stocke le résultat final d’un étudiant
// (moyenne et grade).

class StudentResult {
  final String name;
  final String course;
  final double ca;
  final double finalExam;
  final double avg;
  final String grade;

  StudentResult(
    this.name,
    this.course,
    this.ca,
    this.finalExam,
    this.avg,
    this.grade
  );
}


// =======================
// 2. Logique de calcul
// =======================

// ABSTRACT CLASS
// Une classe abstraite sert de modèle (template).
// Elle ne peut pas être instanciée directement.
// Elle définit une méthode abstraite que les classes
// enfants doivent implémenter.

abstract class GradeProcessor {

  // Méthode concrète
  // Calcule la moyenne de deux notes
  double calculateAverage(double s1, double s2) => (s1 + s2) / 2;

  // Méthode abstraite
  // Elle sera implémentée dans les classes enfants
  String getGrade(double average);
}


// HERITAGE + POLYMORPHISM
// StudentGradeCalculator hérite de GradeProcessor
// et implémente la méthode getGrade().

class StudentGradeCalculator extends GradeProcessor {

  // POLYMORPHISM
  // On redéfinit (override) la méthode getGrade
  // définie dans la classe abstraite.

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
// 3. Traitement du fichier
// =======================

// FILE I/O
// Cette fonction lit un fichier CSV et crée une liste d'objets Student.

List<Student> readStudentsFromCSV(String path) {

  File file = File(path);

  // Vérification si le fichier existe
  if (!file.existsSync()) {
    print("Erreur : Fichier '$path' introuvable.");
    return [];
  }

  try {

    // Lecture de toutes les lignes du fichier
    List<String> lines = file.readAsLinesSync();

    List<Student> students = [];

    // On ignore la première ligne (header)
    for (int i = 1; i < lines.length; i++) {

      if (lines[i].trim().isEmpty) continue;

      var parts = lines[i].split(";");

      if (parts.length >= 4) {

        // Création d'un objet Student
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

    print("Erreur de lecture : $e");
    return [];
  }
}


// =======================
// 4. Statistiques et Export
// =======================

void displayStats(List<StudentResult> results) {

  // MAP COLLECTION
  // On utilise une Map pour stocker la distribution des grades.

  Map<String, int> distribution = {};

  for (var r in results) {

    // Comptage des grades
    distribution[r.grade] = (distribution[r.grade] ?? 0) + 1;
  }

  print("\n===== GRADE DISTRIBUTION =====");

  // LAMBDA FUNCTION
  // Fonction anonyme utilisée dans forEach

  distribution.forEach((grade, count) =>
      print("$grade : $count")
  );


  // HIGHER ORDER FUNCTION
  // where() prend une fonction en paramètre
  // et retourne les éléments qui respectent la condition.

  print("\n===== STUDENTS AT RISK =====");

  var atRisk = results.where(
      (r) => r.grade == "F" || r.grade == "D"
  );

  if (atRisk.isEmpty) {

    print("Aucun étudiant en difficulté.");

  } else {

    for (var s in atRisk) {

      print("${s.name} -> ${s.grade}");
    }
  }
}


// EXPORT FILE

void exportResults(List<StudentResult> results) {

  final outputName = "students_results.csv";

  File file = File(outputName);

  String header =
      "name;course;CA;final_exam;avg;grade\n";


  // HIGHER ORDER FUNCTION + LAMBDA
  // map() transforme chaque objet StudentResult
  // en ligne de texte CSV.

  String content = results.map(
      (r) => "${r.name};${r.course};${r.ca};${r.finalExam};${r.avg};${r.grade}"
  ).join("\n");


  // Écriture dans le fichier
  file.writeAsStringSync(header + content);

  print("\nResults exported to : ${file.absolute.path}");
}


// =======================
// 5. Main
// =======================

void main(List<String> args) {

  // Vérification des arguments du programme
  if (args.isEmpty) {

    print("Usage : dart student_v5.dart <fichier.csv>");
    return;
  }

  String filePath = args[0];


  // Création de l'objet calculateur
  var calculator = StudentGradeCalculator();


  // Lecture du fichier CSV
  List<Student> students = readStudentsFromCSV(filePath);

  if (students.isEmpty) return;


  // HIGHER ORDER FUNCTION + LAMBDA
  // map() applique une fonction à chaque élément de la liste

  List<StudentResult> results = students.map((st) {

    double avg =
        calculator.calculateAverage(st.score1, st.score2);

    return StudentResult(
        st.name,
        st.course,
        st.score1,
        st.score2,
        avg,
        calculator.getGrade(avg)
    );

  }).toList();


  // TRI DE COLLECTION
  // sort() avec une fonction lambda pour trier par moyenne

  results.sort(
      (a, b) => b.avg.compareTo(a.avg)
  );


  print("\n===== STUDENT RESULTS =====");

  for (var r in results) {

    print("${r.name.padRight(12)} | Moyenne: ${r.avg.toStringAsFixed(1)} | Grade: ${r.grade}");
  }


  // Affichage des statistiques
  displayStats(results);

  // Export du fichier
  exportResults(results);
}