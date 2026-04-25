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
Assistant IA (MentorIA)
L’application intègre un Assistant IA puissant qui permet aux étudiants d’obtenir des réponses rapides et pédagogiques en texte (et bientôt en vocal).
Configuration actuelle

Plateforme : Supabase Edge Functions
Nom de la fonction : hf-chat
Lien direct : https://supabase.com/dashboard/project/zgtxzbmhksidcjnqotbx/functions/hf-chat/code
Modèle IA : Llama 3.3 70B Versatile (via Groq)
Clé API : GROQ_API_KEY configurée dans les Variables d’environnement de la fonction sur Supabase

La fonction est déjà déployée et utilise une API compatible OpenAI pour appeler Groq, ce qui garantit des réponses très rapides et de haute qualité.
Prompt système actuel
L’IA est configurée pour agir comme un assistant pédagogique encourageant, spécialisé en informatique, développement web/mobile et technologies ICT.

Comment modifier et redéployer la fonction
Si tu veux modifier le code de la fonction (hf-chat) :

Va sur le lien ci-dessus et édite le code directement dans le dashboard Supabase, ou
Utilise la Supabase CLI (recommandé pour le développement local) :

Bash# 1. Installer la CLI (si ce n’est pas déjà fait)
npm install -g supabase

# 2. Se connecter à ton projet
supabase login

# 3. Lier ton projet local (une seule fois)
supabase link --project-ref zgtxzbmhksidcjnqotbx

# 4. Développer localement (optionnel)
supabase functions serve hf-chat --env-file ./supabase/.env.local

# 5. Déployer la fonction mise à jour
supabase functions deploy hf-chat
Après chaque modification importante, pense à redéployer avec :
Bashsupabase functions deploy hf-chat

Mise à jour dans le code Flutter (ai_page.dart)
Assure-toi que l’URL pointe bien vers ta fonction :
Dartstatic const String _supabaseFunctionUrl =
    'https://zgtxzbmhksidcjnqotbx.supabase.co/functions/v1/hf-chat';
└── models/             → (à venir)
👥 Public cible

Étudiants et stagiaires en formation ICT / Tech
Mentors et formateurs
Centres de formation et écoles supérieures
