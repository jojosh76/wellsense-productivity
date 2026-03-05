// 1️⃣ Interface
interface Publishable {
    fun publish()
}

// 2️⃣ Classe abstraite
abstract class MediaContent(
    val title: String,
    val creator: String
) : Publishable {

    abstract fun getDescription(): String

    override fun toString(): String {
        return "Title: $title | Creator: $creator"
    }
}

// 3️⃣ Data Class (C'est ici qu'étaient tes erreurs)
// Il faut des virgules entre les paramètres et 'Int' avec une majuscule
data class Stud(
    val name: String,
    val university: String,
    val level: Int
)

// 4️⃣ Sous-classe 1
class Video(
    title: String,
    creator: String,
    private val duration: Int // en minutes
) : MediaContent(title, creator) {

    override fun publish() {
        println("Publishing video: $title ($duration mins)")
    }

    override fun getDescription(): String {
        return "Video titled '$title' created by $creator, duration: $duration minutes"
    }
}

// 5️⃣ Sous-classe 2
class GraphicDesign(
    title: String,
    creator: String,
    private val format: String
) : MediaContent(title, creator) {

    override fun publish() {
        println("Publishing design: $title in format $format")
    }

    override fun getDescription(): String {
        return "Graphic design '$title' created by $creator in $format format"
    }
}

// 6️⃣ Fonction Main
fun main() {
    val video = Video("Campus Documentary", "Elysian Media", 15)
    val design = GraphicDesign("Student Election Poster", "Elysian Media", "PDF")

    // Utilisation des noms exacts définis dans la classe Stud
    val student = Stud(
        name = "Joseph",
        university = "Software Engineering",
        level = 4
    )

    val contents: List<MediaContent> = listOf(video, design)

    println("=== Media Contents ===")

    for (content in contents) {
        println(content)
        println(content.getDescription())
        content.publish()
        println()
    }

    println("=== Student Info ===")
    println(student)
}