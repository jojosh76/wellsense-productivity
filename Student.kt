import java.io.File
import java.util.Scanner

// 1. Data Class
data class Student(
    val name: String,
    val course: String,
    val score1: Double,
    val score2: Double
)

// 2. Classe Abstraite pour la logique de calcul
abstract class GradeProcessor {

    // Méthode concrète pour calculer la moyenne
    fun calculateAverage(s1: Double, s2: Double): Double {
        return (s1 + s2) / 2
    }

    // Méthode abstraite que la sous-classe doit implémenter
    abstract fun getGrade(average: Double): String

    // Méthode "Template" qui orchestre le processus (Logique imposée)
    fun process(student: Student): String {
        if (student.score1 !in 0.0..100.0 || student.score2 !in 0.0..100.0) {
            return "Invalide"
        }
        val average = calculateAverage(student.score1, student.score2)
        return getGrade(average)
    }
}

// 3. Implémentation concrète
class StudentGradeCalculator : GradeProcessor() {
    override fun getGrade(average: Double): String {
        return when {
            average >= 80 -> "A"
            average >= 70 -> "B"
            average >= 60 -> "C+"
            average >= 50 -> "C"
            average >= 40 -> "D"
            else -> "F"
        }
    }
}

// 4. Fonction Export CSV
fun exportToCSV(results: List<Map<String, String>>) {
    val file = File("students_results.csv")
    val header = "STUDENT,COURSE,AVG,GRADE\n"

    val content = results.joinToString("\n") { res ->
        "${res["name"]},${res["course"]},${res["avg"]},${res["grade"]}"
    }

    file.writeText(header + content)
    println("\nFichier CSV généré : ${file.absolutePath}")
}

// 5. Main Function
fun main() {
    val reader = Scanner(System.`in`)
    val calculator = StudentGradeCalculator()
    val students = mutableListOf<Student>()

    print("Combien d'étudiants ? ")
    val number = reader.nextLine().toIntOrNull() ?: 0

    for (i in 1..number) {
        println("\n--- Étudiant $i ---")

        print("Nom : ")
        val name = reader.nextLine().ifBlank { "Inconnu" }

        print("Cours : ")
        val course = reader.nextLine().ifBlank { "N/A" }

        print("CA  : ")
        val s1 = reader.nextLine().replace(',', '.').toDoubleOrNull() ?: 0.0

        print("Final exam : ")
        val s2 = reader.nextLine().replace(',', '.').toDoubleOrNull() ?: 0.0

        students.add(Student(name, course, s1, s2))
    }

    // Traitement des résultats via la classe abstraite
    val resultList = students.map { st ->
        mapOf(
            "name" to st.name,
            "course" to st.course,
            "avg" to String.format("%.2f", calculator.calculateAverage(st.score1, st.score2)),
            "grade" to calculator.process(st)
        )
    }

    // Affichage Console
    println("\n========== TABLEAU DES RÉSULTATS ==========")
    println("%-15s %-15s %-8s %-5s".format("NOM", "COURS", "MOY", "GRADE"))
    println("-".repeat(50))

    resultList.forEach { res ->
        println("%-15s %-15s %-8s %-5s".format(res["name"], res["course"], res["avg"], res["grade"]))
    }

    exportToCSV(resultList)
}