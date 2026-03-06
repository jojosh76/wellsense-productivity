// Sealed Class
sealed class NetworkState {}

class Loading extends NetworkState {}

class Success extends NetworkState {
  final String data;
  Success(this.data);
}

class Error extends NetworkState {
  final String message;
  Error(this.message);
}

// Fonction pour gérer les états
void handleState(NetworkState state) {
  // En Dart, le 'switch' sur une sealed class est exhaustif
  switch (state) {
    case Loading():
      print("Loading... Please wait.");
    case Success(data: var d):
      print("Success: $d");
    case Error(message: var m):
      print("Error: $m");
  }
}

// Exemple d'utilisation
void main() {
  final states = [
    Loading(),
    Success("User data loaded"),
    Error("Network timeout"),
  ];

  for (var state in states) {
    handleState(state);
  }
}