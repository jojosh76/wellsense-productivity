class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}

void main() {
  final people = [
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 35),
    Person("Anna", 22),
    Person("Ben", 28),
  ];

  // Filtrage
  final filteredPeople = people.where((it) => 
      it.name.startsWith("A") || it.name.startsWith("B")
  ).toList();

  // Mapping
  final ages = filteredPeople.map((it) => it.age).toList();

  // Moyenne (average() existe sur Iterable<int> dans le package 'dart:collection' ou via extension)
  final averageAge = ages.isEmpty ? 0.0 : ages.reduce((a, b) => a + b) / ages.length;

  print("Average age: ${averageAge.toStringAsFixed(1)}");
}