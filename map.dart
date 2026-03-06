void main() {
  final words = ["apple", "cat", "banana", "dog", "elephant"];

  // Création de la map
  final wordMap = {for (var word in words) word: word.length};

  // Filtrage
  final filteredWords = Map.fromEntries(
    wordMap.entries.where((entry) => entry.value > 4),
  );

  filteredWords.forEach((key, value) {
    print("$key has length $value");
  });
}