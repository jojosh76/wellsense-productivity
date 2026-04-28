# InternsHelp 

**Plateforme mobile de gestion de stages et de mentorat**

InternsHelp est une application Flutter conçue pour simplifier la gestion des stages et du mentorat, particulièrement au sein de l’**ICT (Institut des Technologies du Cameroun)**.


## Problème Résolu

Les stagiaires et étudiants font souvent face à :
- Difficulté à trouver un mentor adapté
- Manque de suivi structuré des tâches pendant le stage
- Communication fragmentée avec les encadreurs
- Accès difficile aux ressources pédagogiques
- Gestion manuelle et peu claire des évaluations et feedbacks



## Solution

**InternsHelp** centralise l’ensemble du processus de stage dans une seule application :

- Mise en relation étudiants ↔ mentors
- Suivi avancé des tâches avec soumission de travaux
- Espace de cours et partage de ressources
- Communication en temps réel (chat + vocal)
- Assistant IA intégré
- Évaluations et feedback formalisés



## Fonctionnalités Principales

###  Authentification & Rôles
- Inscription et connexion (Email + Google)
- Détection automatique du rôle (`student` / `mentor`) selon le domaine de l’email (`@ict.cm`)
- Gestion de profil avec photo

### Mentorat
- Annuaire des mentors
- Envoi et gestion des demandes de mentorat
- Acceptation / refus par les mentors
- Discussions privées (texte, images, messages vocaux)

###  Cours & Ressources
- Catalogue de cours
- Ajout de documents (liens Drive, Google Meet, etc.)
- Scan de supports physiques via caméra
- Accès restreint selon le rôle (mentor/admin)

###  Gestion des Tâches
- Création de tâches par les mentors
- Tableau de suivi type Kanban (`À faire` / `En cours` / `En attente de feedback` / `Terminé`)
- Soumission de travaux (photos ou fichiers)
- Feedback détaillé + évaluation (note technique & autonomie)
- Priorité et dates d’échéance

###  AI Assistant
- Assistant conversationnel basé sur **Groq + Llama 3.3**
- Support vocal (speech-to-text)
- Accessible directement depuis le menu

###  Discussion & Notifications
- Chat privé riche en médias
- Gestion centralisée des demandes de mentorat

###  Autres fonctionnalités
- Intégration Google Meet pour les sessions
- Évaluations techniques et d’autonomie
- Design moderne et responsive

---

## Architecture Technique

- **Frontend** : Flutter (single codebase – Android, iOS, Web)
- **Backend** : Firebase (Authentication, Firestore, Storage)
- **IA** : Supabase Edge Function + Groq API (Llama 3.3 70B)
- **Architecture** : Modulaire par feature
  - `pages/` – Écrans de l’application
  - `services/` – Couche métier (TaskService, PostService, etc.)
  - `models/` – Modèles de données (`TaskModel`)
  - `auth/` – Gestion de l’authentification

**Technologies clés** :
- Firebase Firestore (temps réel)
- Firebase Storage (médias)
- `speech_to_text`, `image_picker`, `just_audio`, `url_launcher`
- HTTP + Supabase Functions


 Installation & Lancement

 Prérequis
- Flutter SDK (version stable recommandée)
- Projet Firebase configuré
- Clé Groq configurée dans les variables d’environnement Supabase (pour l’IA)

Étapes

1. **Cloner le repository**
   
   git clone https://github.com/votre-org/internshelp.git
   cd internshelp
   

2. **Installer les dépendances**
   **flutter pub get**

3. **Configurer Firebase**
   - Assurez-vous que `lib/firebase_options.dart` est correctement configuré

4. Lancer l’application
   
   **flutter run**
   

## Structure du Projet

lib/
├── auth/               # Services d'authentification
├── models/             # Modèles de données (TaskModel, etc.)
├── services/           # Services Firestore et logique métier
├── pages/              # Toutes les pages de l'application
│   ├── ai_page.dart
│   ├── course_page.dart
│   ├── discussion_page.dart
│   ├── task_management_page.dart
│   └── ...
└── main.dart
