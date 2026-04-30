import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ CORRIGÉ : alias 'fb_storage' pour éviter le conflit avec la classe Task de task_model.dart
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  late String _currentUserId;
  late bool _isStudent;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _determineUserRole();
  }

  void _determineUserRole() {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    _isStudent = !email.endsWith('@ict.cm');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Détails de la Tâche"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // ✅ CORRIGÉ : FutureBuilder<TaskModel> utilise bien le bon type
      body: FutureBuilder<TaskModel?>(
        future: _taskService.getTaskById(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 80, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text("Tâche introuvable"),
                ],
              ),
            );
          }

          final task = snapshot.data!;
          final isTaskOwner = _currentUserId == task.studentId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(task),
                const SizedBox(height: 24),

                _buildInfoSection(
                  icon: Icons.description,
                  title: "Description",
                  content: task.description,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        "Statut",
                        _getStatusLabel(task.status),
                        _getStatusColor(task.status),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoBox(
                        "Priorité",
                        task.priority.toUpperCase(),
                        _getPriorityColor(task.priority),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (task.dueDate != null)
                  _buildInfoSection(
                    icon: Icons.calendar_today,
                    title: "Date Limite",
                    content: _formatDate(task.dueDate!),
                  ),
                const SizedBox(height: 16),

                if (task.status == 'pending_review' || task.submissionUrl != null)
                  _buildSubmissionInfo(task),
                const SizedBox(height: 16),

                if (task.feedback != null)
                  _buildFeedbackSection(task),
                const SizedBox(height: 16),

                if (isTaskOwner && _isStudent)
                  _buildStudentActions(task, context),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(task.mentorId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final mentorName = snapshot.data?['name'] ?? "Encadreur";
              return Text(
                "Assigné par: $mentorName",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionInfo(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.file_present, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Soumission",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (task.submittedAt != null)
            Text(
              "Soumis le: ${_formatDateTime(task.submittedAt!)}",
              style: const TextStyle(fontSize: 12),
            ),
          if (task.submissionUrl != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openSubmissionUrl(task.submissionUrl!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Voir la soumission",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.feedback, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Feedback de l'Encadreur",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.feedback!,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentActions(TaskModel task, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (task.status == 'todo')
          ElevatedButton.icon(
            onPressed: () => _updateStatus(task.id!, 'in_progress'),
            icon: const Icon(Icons.play_arrow),
            label: const Text("Commencer la Tâche"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (task.status == 'in_progress')
          ElevatedButton.icon(
            onPressed: () => _showSubmissionDialog(task.id!, context),
            icon: const Icon(Icons.upload_file),
            label: const Text("Soumettre ma Soumission"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (task.status == 'pending_review')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple),
            ),
            child: const Column(
              children: [
                Icon(Icons.schedule, color: Colors.purple, size: 32),
                SizedBox(height: 8),
                Text(
                  "En attente de feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        if (task.status == 'done')
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(height: 8),
                Text(
                  "Tâche Complétée",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'todo':
        return "À Faire";
      case 'in_progress':
        return "En Cours";
      case 'pending_review':
        return "En Attente";
      case 'done':
        return "Complété";
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'todo':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'pending_review':
        return Colors.purple;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _updateStatus(String taskId, String newStatus) async {
    try {
      await _taskService.updateTaskStatus(taskId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ✅ CORRIGÉ : interpolation avec {} autour de l'appel de méthode
            content: Text("Statut mis à jour en ${_getStatusLabel(newStatus)}"),
            backgroundColor: Colors.green,
          ),
        );
        // Recharger la page
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSubmissionDialog(String taskId, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Soumettre votre Travail"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sélectionnez un fichier ou une photo à soumettre",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _pickAndUploadFile(taskId, context, isCamera: false),
              icon: const Icon(Icons.folder),
              label: const Text("Sélectionner un Fichier"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  _pickAndUploadFile(taskId, context, isCamera: true),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Prendre une Photo"),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAndUploadFile(String taskId, BuildContext context,
      {required bool isCamera}) async {
    try {
      XFile? file;
      final picker = ImagePicker();

      if (isCamera) {
        file = await picker.pickImage(source: ImageSource.camera);
      } else {
        file = await picker.pickImage(source: ImageSource.gallery);
      }

      if (file == null) return;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text("Envoi en cours..."),
                ],
              ),
            ),
          ),
        );
      }

      // ✅ CORRIGÉ : utilise fb_storage.FirebaseStorage (alias) pour éviter conflit
      final storageRef = fb_storage.FirebaseStorage.instance.ref().child(
            'task_submissions/$_currentUserId/$taskId/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

      final bytes = await file.readAsBytes();
      await storageRef.putData(bytes);
      final downloadUrl = await storageRef.getDownloadURL();

      await _taskService.submitTask(taskId, downloadUrl);

      if (mounted) {
        Navigator.pop(context); // Fermer le loading
        Navigator.pop(context); // Fermer le dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Soumission réussie !"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Recharger les données
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openSubmissionUrl(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                url,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stack) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Fermer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
