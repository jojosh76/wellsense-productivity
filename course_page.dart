import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart'; // Import ajouté

class CoursePage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CoursePage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String? userRole;
  bool loadingRole = true;
  final ImagePicker _picker = ImagePicker(); // Initialisation

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => loadingRole = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'student';
          loadingRole = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingRole = false);
    }
  }

  Future<void> _startGoogleMeet() async {
    final uri = Uri.parse("https://meet.google.com/new");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDocumentUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // --- NOUVELLE FONCTION PHOTO ---
  Future<void> _takeDocumentPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document capturé !")),
      );
    }
  }

  void _showEvaluationDialog(BuildContext context, String moduleTitle, String moduleId) {
    final score1Ctrl = TextEditingController();
    final score2Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Évaluer : $moduleTitle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: score1Ctrl, 
              decoration: const InputDecoration(labelText: "Note Technique (0-100)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: score2Ctrl, 
              decoration: const InputDecoration(labelText: "Note Autonomie (0-100)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              double s1 = double.tryParse(score1Ctrl.text.replaceAll(',', '.')) ?? 0;
              double s2 = double.tryParse(score2Ctrl.text.replaceAll(',', '.')) ?? 0;
              double avg = (s1 + s2) / 2;
              
              String grade = "F";
              if (avg >= 80) grade = "A";
              else if (avg >= 70) grade = "B";
              else if (avg >= 60) grade = "C+";
              else if (avg >= 50) grade = "C";

              await FirebaseFirestore.instance.collection('evaluations').add({
                'moduleId': moduleId,
                'moduleTitle': moduleTitle,
                'courseId': widget.courseId,
                'studentId': FirebaseAuth.instance.currentUser?.uid,
                'average': avg,
                'grade': grade,
                'timestamp': FieldValue.serverTimestamp(),
              });

              if (mounted) Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Évaluation enregistrée : Grade $grade")),
              );
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  void _openAddContentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajouter à ${widget.courseTitle}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Nom du document")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Lien Drive/URL")),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _takeDocumentPhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Scanner un support physique"),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (urlCtrl.text.isNotEmpty && titleCtrl.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('documents')
                    .add({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'url': urlCtrl.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.video_call), onPressed: _startGoogleMeet),
          if (!loadingRole && (userRole == 'mentor' || userRole == 'admin'))
            IconButton(icon: const Icon(Icons.add_link), onPressed: _openAddContentDialog),
        ],
      ),
      body: loadingRole 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .collection('documents')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Erreur"));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.description, color: Colors.blueAccent),
                      title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userRole == 'mentor' || userRole == 'admin')
                            IconButton(
                              icon: const Icon(Icons.star_rate, color: Colors.orange),
                              onPressed: () => _showEvaluationDialog(context, data['title'], docId),
                            ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, color: Colors.blue),
                            onPressed: () => _openDocumentUrl(data['url'] ?? ''),
                          ),
                          if (userRole == 'admin' || userRole == 'mentor')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => FirebaseFirestore.instance.collection('courses').doc(widget.courseId).collection('documents').doc(docId).delete(),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}