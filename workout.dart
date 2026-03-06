/**
 * Project Milestone 3: Object-Oriented Domain Model
 * Conversion de Kotlin vers Dart
 */

// 1. COMPORTEMENT : En Dart, on utilise 'abstract class' pour les interfaces [cite: 219, 223]
abstract class Loggable {
  String getSummary();
}

// 2. ÉTATS : Dart n'a pas de 'sealed class' identique avant Dart 3.0. 
// On utilise une classe abstraite de base.
abstract class NetworkState {}

class Loading extends NetworkState {}

class Success extends NetworkState {
  final String data;
  Success(this.data);
}

class Error extends NetworkState {
  final String message;
  Error(this.message);
}

// 3. BASE : Classe Abstraite [cite: 219, 223]
abstract class Workout implements Loggable {
  final String name;
  final int durationMinutes;

  // Constructeur Dart 
  Workout(this.name, this.durationMinutes);

  int calculateCalories();
}

// 4. MODÈLE : Dart n'a pas de 'data class' native (Page 23) [cite: 224, 227]
// On définit les propriétés final et le constructeur.
class UserProfile {
  final String username;
  final double weightKg;

  UserProfile(this.username, this.weightKg);

  @override
  String toString() => 'UserProfile(username: $username, weightKg: $weightKg)';
}

// 5. CLASSES CONCRÈTES (Héritage via 'extends') [cite: 220, 222]
class Running extends Workout {
  final double distanceKm;

  Running(int duration, this.distanceKm) : super("Running", duration);

  @override
  int calculateCalories() => (distanceKm * 60).toInt();

  @override
  String getSummary() => '$name: $distanceKm km en $durationMinutes min';
}

class Yoga extends Workout {
  final String intensity;

  Yoga(int duration, this.intensity) : super("Yoga", duration);

  @override
  int calculateCalories() => durationMinutes * 4;

  @override
  String toString() => 'Yoga ($intensity) - $durationMinutes min';

  @override
  String getSummary() => '$name intensity $intensity';
}

// 6. LOGIQUE DE TRAITEMENT (Similaire au 'when' de Kotlin) [cite: 180, 217]
void handleState(NetworkState state) {
  if (state is Loading) {
    print("Chargement en cours...");
  } else if (state is Success) {
    print("Données reçues : ${state.data}");
  } else if (state is Error) {
    print("Erreur réseau : ${state.message}");
  }
}

void main() {
  // Profil utilisateur
  var user = UserProfile("Daniel", 80.0);
  print("Utilisateur : $user");

  // Polymorphisme dans une collection (Page 22) [cite: 218, 220]
  List<Workout> activities = [
    Running(30, 5.0),
    Yoga(60, "Zen")
  ];
  
  print("\n--- Calcul des activités ---");
  for (var workout in activities) {
    print("${workout.getSummary()} -> ${workout.calculateCalories()} kcal");
  }

  // Démonstration de l'état réseau
  print("\n--- Test État Réseau ---");
  handleState(Success("Profil synchronisé"));
}