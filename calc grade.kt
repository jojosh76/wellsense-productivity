import java.util.Scanner

// Définition de la classe (Nom avec une majuscule par convention)
class calc(
    val name: String,
    val score: Double?
)

// Fonction de calcul du grade
fun calculateGrade(score: Double): String {
    return when {
        score >= 80 && score <= 100 -> "A"
        score >= 70 -> "B"
        score >= 60 -> "C+"
        score >= 50 -> "C"
        score >= 40 -> "D"
        score >= 0  -> "F"
        else -> "Invalid Score"
    }
}

fun main() {
    val reader = Scanner(System.`in`)

    // Lecture du nom
    print("Enter student name: ")
    val inputName = reader.nextLine()?.trim()
    val name = if (!inputName.isNullOrEmpty()) inputName else "Unknown"

    // Lecture du score
    print("Enter student score (0 - 100): ")
    val inputScore = if (reader.hasNext()) reader.next().trim() else ""
    val score = inputScore.replace(',', '.').toDoubleOrNull() // Gère les virgules ou points

    // Création de l'objet Student
    val student = Student(name, score)
    val finalResult: String

    // Logique de validation et formatage du résultat
    if (score == null) {
        finalResult = "Error: Invalid input! Please enter a valid number."
    } else if (score < 0 || score > 100) {
        finalResult = "Error: Score must be between 0 and 100."
    } else {
        val grade = calculateGrade(score)
        finalResult = """
            Student: ${student.name}
            Score: $score
            Grade: $grade
        """.trimIndent()
    }

    // Affichage final
    println("\n----- RESULT -----")
    println(finalResult)
}