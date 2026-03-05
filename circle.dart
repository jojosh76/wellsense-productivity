// 1️⃣ Interface (En Dart, une classe abstraite sert d'interface)
abstract interface class Drawable {
  void draw();
}

// 2️⃣ Classe Circle
class Circle implements Drawable {
  // Le préfixe '_' simule le 'private' de Kotlin pour ce fichier
  final int _radius;

  Circle(this._radius);

  @override
  void draw() {
    print("Drawing Circle with radius $_radius");
    print("  *** ");
    print("*     * ");
    print("*     * ");
    print("  *** ");
    print(""); // Équivalent du println() vide
  }
}

// 3️⃣ Classe Square
class Square implements Drawable {
  final int _side;

  Square(this._side);

  @override
  void draw() {
    print("Drawing Square with side $_side");
    print(" ***** ");
    print(" *   * ");
    print(" *   * ");
    print(" ***** ");
    print("");
  }
}

// 4️⃣ Fonction main
void main() {
  // Création des objets
  final circle = Circle(5);
  final square = Square(4);

  // Liste polymorphique
  final List<Drawable> shapes = [circle, square];

  // Appel polymorphique (forEach)
  shapes.forEach((shape) {
    shape.draw();
  });
}