import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
// ✅ CORRIGÉ : casse du fichier corrigée (T majuscule)
import 'Tasks_detail_page.dart';

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  final TaskService _taskService = TaskService();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Gestion des Tâches"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showCreateTaskDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskService.getTasksForMentor(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune tâche créée",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Appuyez sur + pour en créer une",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!;
          final pendingTasks =
              tasks.where((t) => t.status == 'pending_review').toList();
          final activeTasks = tasks
              .where((t) => t.status == 'todo' || t.status == 'in_progress')
              .toList();
          final completedTasks = tasks.where((t) => t.status == 'done').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Résumé
                _buildSummaryCards(tasks),
                const SizedBox(height: 24),

                // Tâches en attente de feedback
                if (pendingTasks.isNotEmpty) ...[
                  Text(
                    "⏳ En Attente de Feedback (${pendingTasks.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildTasksList(pendingTasks, context),
                  const SizedBox(height: 24),
                ],

                // Tâches actives
                Text(
                  "▶️ En Cours (${activeTasks.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                if (activeTasks.isEmpty)
                  Text(
                    "Aucune tâche active",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ..._buildTasksList(activeTasks, context),
                const SizedBox(height: 24),

                // Tâches complétées
                Text(
                  "✅ Complétées (${completedTasks.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                if (completedTasks.isEmpty)
                  Text(
                    "Aucune tâche complétée",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ..._buildTasksList(completedTasks, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Task> tasks) {
    int total = tasks.length;
    int pending = tasks.where((t) => t.status == 'pending_review').length;
    int completed = tasks.where((t) => t.status == 'done').length;

    return Row(
      children: [
        _buildSummaryCard("Total", total, Colors.blue),
        const SizedBox(width: 12),
        _buildSummaryCard("En Attente", pending, Colors.purple),
        const SizedBox(width: 12),
        _buildSummaryCard("Complétées", completed, Colors.green),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTasksList(List<Task> tasks, BuildContext context) {
    return tasks.map((task) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(taskId: task.id!),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(task.studentId)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox.shrink();
                              final studentName =
                                  snapshot.data?['name'] ?? "Étudiant";
                              return Text(
                                "Assigné à: $studentName",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(task.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Priorité et date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                    if (task.dueDate != null)
                      Text(
                        "Échéance: ${_formatDate(task.dueDate!)}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),

                // Boutons d'action pour les tâches en attente
                if (task.status == 'pending_review')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _approveFeedback(task.id!),
                            child: const Text(
                              "Approuver",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () =>
                                _showFeedbackDialog(task.id!, context),
                            child: const Text(
                              "Feedback",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'todo':
        color = Colors.orange;
        label = "À Faire";
        break;
      case 'in_progress':
        color = Colors.blue;
        label = "En Cours";
        break;
      case 'pending_review':
        color = Colors.purple;
        label = "En Attente";
        break;
      case 'done':
        color = Colors.green;
        label = "Complété";
        break;
      default:
        color = Colors.grey;
        label = "Inconnu";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
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

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateTaskDialog(taskService: _taskService),
    );
  }

  void _showFeedbackDialog(String taskId, BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un Feedback"),
        content: TextField(
          controller: feedbackController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Écrivez votre feedback ici...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final feedback = feedbackController.text.trim();
              if (feedback.isNotEmpty) {
                try {
                  await _taskService.addFeedback(taskId, feedback, 'todo');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Feedback ajouté"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  void _approveFeedback(String taskId) async {
    try {
      await _taskService.updateTaskStatus(taskId, 'done');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tâche approuvée"),
            backgroundColor: Colors.green,
          ),
        );
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
}

class _CreateTaskDialog extends StatefulWidget {
  final TaskService taskService;

  const _CreateTaskDialog({required this.taskService});

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedPriority = 'medium';
  DateTime? selectedDueDate;
  String? selectedStudentId;
  String? selectedMentorshipId;
  List<Map<String, dynamic>> mentorships = [];

  @override
  void initState() {
    super.initState();
    _loadMentorships();
  }

  void _loadMentorships() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('mentorships')
        .where('mentorId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'accepted')
        .get();

    setState(() {
      mentorships = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'studentId': doc['studentId'],
                'studentName': doc['studentName'],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Créer une Tâche",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Titre
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Titre de la tâche",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stagiaire
            DropdownButtonFormField<String>(
              value: selectedStudentId,
              hint: const Text("Sélectionner un stagiaire"),
              items: mentorships.map((m) {
                return DropdownMenuItem<String>(
                  value: m['studentId'] as String,
                  child: Text(m['studentName'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStudentId = value;
                  final match = mentorships.firstWhere(
                    (m) => m['studentId'] == value,
                    orElse: () => {},
                  );
                  selectedMentorshipId = match['id'] as String?;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Priorité
            DropdownButtonFormField<String>(
              value: selectedPriority,
              items: ['low', 'medium', 'high']
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedPriority = value ?? 'medium'),
              decoration: InputDecoration(
                labelText: "Priorité",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Date limite
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(selectedDueDate == null
                  ? "Sélectionner une date limite"
                  : "Date: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDueDate = date);
                }
              },
            ),
            const SizedBox(height: 16),

            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: selectedStudentId == null
                      ? null
                      : () async {
                          try {
                            await widget.taskService.createTask(
                              mentorId:
                                  FirebaseAuth.instance.currentUser!.uid,
                              studentId: selectedStudentId!,
                              mentorshipId: selectedMentorshipId!,
                              title: titleController.text,
                              description: descriptionController.text,
                              priority: selectedPriority,
                              dueDate: selectedDueDate,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Tâche créée"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Erreur: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  child: const Text("Créer"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
