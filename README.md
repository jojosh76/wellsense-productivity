
 Student Grade Manager (Dart CSV Edition)

Ce projet est une application console robuste développée en Dart. Elle permet de gérer les notes des étudiants, de les sauvegarder de manière persistante dans un fichier CSV, de traiter les résultats (calcul de moyenne et attribution de grades) et d'exporter le bilan final.

 Fonctionnalités

Saisie Interactive : Collecte dynamique des noms, cours et notes (CA et Examen Final).
Calcul Automatisé : Traitement des moyennes et attribution de grades (A, B, C+, etc.).
Persistance des Données : Sauvegarde des entrées brutes dans `students.csv`.
Exportation Professionnelle : Génération d'un rapport complet dans `students_results.csv`.
Gestion des Erreurs: Validation des notes (0-100) et gestion du parsing sécurisé.

---

 Architecture & Concepts Programmation

Le projet repose sur des concepts fondamentaux de la programmation moderne (POO et Fonctionnel) :

1. Programmation Orientée Objet (POO)
Encapsulation : Utilisation de la classe `Student` pour structurer les données.
Abstraction : La classe `GradeProcessor` définit un contrat de traitement des notes.
Polymorphisme : `StudentGradeCalculator` implémente la logique spécifique de notation.

2. Programmation Fonctionnelle
Higher-Order Functions : Utilisation massive de `.map()` pour transformer les listes d'objets en flux de données CSV.
Lambdas: Fonctions anonymes pour un traitement de données concis.

3. Gestion I/O (Entrées/Sorties)
File System : Lecture et écriture synchrone avec la bibliothèque `dart:io`.
Null Safety : Utilisation intensive des opérateurs `??` et `tryParse` pour éviter les plantages.

---

 Structure des Fichiers de Sortie

| Fichier | Rôle |
| :--- | :--- |
| `students.csv` | Stocke les données brutes saisies (Source de vérité). |
| `students_results.csv` | Contient le rapport final : moyennes et grades calculés. |

---

 Installation et Utilisation

 Prérequis
 Avoir le SDK **Dart installé.

 Exécution
1.  Clone ce dépôt ou copie le fichier `main.dart`.
2.  Ouvre un terminal dans le dossier du projet.
3.  Lance l'application avec la commande suivante :
    ```bash
    dart main.dart
    ```

 Barème des Grades
Le système utilise la logique suivante pour l'attribution des grades :
A : >= 80%
B : >= 70%
C+ : >= 60%
C : >= 50%
D : >= 40%
F : < 40%

---



Souhaites-tu que j'ajoute une section spécifique sur la configuration de VS Code pour ce projet ?
