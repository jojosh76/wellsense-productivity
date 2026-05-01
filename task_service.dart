import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= CREATE =================
  Future<String> createTask({
    required String mentorId,
    required String studentId,
    required String mentorshipId,
    required String title,
    required String description,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      final docRef = await _firestore.collection('tasks').add({
        'mentorId': mentorId,
        'studentId': studentId,
        'mentorshipId': mentorshipId,
        'title': title,
        'description': description,
        'status': 'todo',
        'priority': priority,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'submittedAt': null,
        'submissionUrl': null,
        'feedback': null,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur création tâche: $e');
    }
  }

  // ================= READ =================
  // Récupérer toutes les tâches d'un stagiaire
  Stream<List<Task>> getTasksForStudent(String studentId) {
    return _firestore
        .collection('tasks')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Récupérer toutes les tâches d'un encadreur
  Stream<List<Task>> getTasksForMentor(String mentorId) {
    return _firestore
        .collection('tasks')
        .where('mentorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  // Récupérer une tâche spécifique
  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      return doc.exists ? Task.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Erreur récupération tâche: $e');
    }
  }

  // ================= UPDATE =================
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur mise à jour statut: $e');
    }
  }

  Future<void> submitTask(String taskId, String submissionUrl) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'pending_review',
        'submissionUrl': submissionUrl,
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur soumission: $e');
    }
  }

  Future<void> addFeedback(String taskId, String feedback, String status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'feedback': feedback,
        'status': status, // "done" ou "todo" pour révision
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur feedback: $e');
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('tasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Erreur mise à jour: $e');
    }
  }

  // ================= DELETE =================
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Erreur suppression: $e');
    }
  }

  // ================= STATISTICS =================
  Future<Map<String, int>> getTaskStats(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('studentId', isEqualTo: studentId)
          .get();

      final tasks = snapshot.docs;
      int todo = 0,
          inProgress = 0,
          done = 0,
          pending = 0;

      for (var doc in tasks) {
        final status = doc['status'] as String;
        switch (status) {
          case 'todo':
            todo++;
            break;
          case 'in_progress':
            inProgress++;
            break;
          case 'done':
            done++;
            break;
          case 'pending_review':
            pending++;
            break;
        }
      }

      return {
        'todo': todo,
        'in_progress': inProgress,
        'done': done,
        'pending_review': pending,
      };
    } catch (e) {
      throw Exception('Erreur stats: $e');
    }
  }
}
