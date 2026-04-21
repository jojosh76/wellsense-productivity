# MentorIA

**Plateforme d’apprentissage collaboratif avec IA et mentorat**

Une application Flutter mobile qui connecte étudiants, mentors et intelligence artificielle pour un apprentissage moderne et efficace.

## ✨ Fonctionnalités principales

- **Tableau de bord** : Accès rapide aux cours disponibles
- **Discussion en temps réel** : Chat texte + messages vocaux + images
- **Assistant IA** : Conversation intelligente (texte et voix)
- **Mentorat** : Trouver un mentor, envoyer une demande, gestion des statuts
- **Espace Cours** : Documents, liens, visioconférence Google Meet, évaluations
- **Notifications** : Suivi des demandes de mentorat
- **Authentification** : Email / Google + gestion des rôles (student / mentor / admin)

## 🛠️ Stack Technique

- **Frontend** : Flutter (mobile-first)
- **Backend** : Firebase (Firestore, Authentication, Storage)
- **IA** : Supabase Edge Function + Hugging Face
- **Enregistrement vocal** : package `record`
- **Lecture audio** : `just_audio`
- **Photos** : `image_picker`

## 📱 Installation

1. Clone le repository
   ```bash
   git clone <url-du-repo>
   cd mentor_ia

Installe les dépendancesBashflutter pub get
Configure Firebase
Ajoute ton fichier google-services.json (Android)
Ajoute ton fichier GoogleService-Info.plist (iOS)
Mets à jour les clés Supabase dans ai_page.dart

Lance l’applicationBashflutter run

📂 Structure du projet
textlib/
├── pages/              → Toutes les pages (Dashboard, Discussion, AI, etc.)
├── auth/               → Authentification
├── services/           → Services Firestore & Storage
└── models/             → (à venir)
👥 Public cible

Étudiants et stagiaires en formation ICT / Tech
Mentors et formateurs
Centres de formation et écoles supérieures
