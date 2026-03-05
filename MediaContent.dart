// 1️⃣ Interface (En Dart, toute classe peut être une interface)
abstract interface class Publishable {
  void publish();
}

// 2️⃣ Classe abstraite
abstract class MediaContent implements Publishable {
  final String title;
  final String creator;

  MediaContent(this.title, this.creator);

  String getDescription();

  @override
  String toString() {
    return "Title: $title | Creator: $creator";
  }
}

// 3️⃣ Equivalent d'une Data Class (Écrite manuellement en Dart pur)
class Student {
  final String name;
  final String university;
  final int level;

  const Student({
    required this.name, 
    required this.university, 
    required this.level
  });

  // En Dart, on surcharge manuellement pour simuler une data class
  @override
  String toString() => 'Student(name: $name, university: $university, level: $level)';
}

// 4️⃣ Sous-classe 1
class Video extends MediaContent {
  final int duration; // en minutes

  Video(String title, String creator, this.duration) : super(title, creator);

  @override
  void publish() {
    print("Publishing video: $title ($duration mins)");
  }

  @override
  String getDescription() {
    return "Video titled '$title' created by $creator, duration: $duration minutes";
  }
}

// 5️⃣ Sous-classe 2
class GraphicDesign extends MediaContent {
  final String format;

  GraphicDesign(String title, String creator, this.format) : super(title, creator);

  @override
  void publish() {
    print("Publishing design: $title in format $format");
  }

  @override
  String getDescription() {
    return "Graphic design '$title' created by $creator in $format format";
  }
}

// 6️⃣ Fonction Main
void main() {
  final video = Video("Campus Documentary", "Elysian Media", 15);
  final design = GraphicDesign("Student Election Poster", "Elysian Media", "PDF");

  final student = Student(name: "Joseph", university: "Software Engineering", level: 4);

  // Polymorphisme
  final List<MediaContent> contents = [video, design];

  print("=== Media Contents ===");

  for (var content in contents) {
    print(content);               // Appelle toString()
    print(content.getDescription());
    content.publish();            // Appel polymorphique
    print("");
  }

  print("=== Student Info (Simulated Data Class) ===");
  print(student);                 // Utilise le toString() surchargé
}