List<int> processList(List<int> numbers, bool Function(int) predicate) {
  final result = <int>[];

  for (final number in numbers) {
    if (predicate(number)) {
      result.add(number);
    }
  }

  return result;
}

void main() {
  final nums = [1, 2, 3, 4, 5, 6];

  // En Dart, on utilise des fonctions fléchées (arrow functions)
  final even = processList(nums, (it) => it % 2 == 0);

  print(even); // [2, 4, 6]
}