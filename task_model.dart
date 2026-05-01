import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ CORRIGÉ : classe renommée TaskModel pour éviter le conflit
// avec la classe Task exportée par firebase_storage
class TaskModel {
  final String? id;
  final String mentorId;
  final String studentId;
  final String mentorshipId;
  final String title;
  final String description;
  final String status; // 'todo' | 'in_progress' | 'pending_review' | 'done'
  final String priority; // 'low' | 'medium' | 'high'
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? submissionUrl;
  final String? feedback;

  TaskModel({
    this.id,
    required this.mentorId,
    required this.studentId,
    required this.mentorshipId,
    required this.title,
    required this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.dueDate,
    required this.createdAt,
    this.submittedAt,
    this.submissionUrl,
    this.feedback,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      studentId: data['studentId'] ?? '',
      mentorshipId: data['mentorshipId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'todo',
      priority: data['priority'] ?? 'medium',
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      submittedAt: data['submittedAt'] != null
          ? (data['submittedAt'] as Timestamp).toDate()
          : null,
      submissionUrl: data['submissionUrl'],
      feedback: data['feedback'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'studentId': studentId,
      'mentorshipId': mentorshipId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'submittedAt':
          submittedAt != null ? Timestamp.fromDate(submittedAt!) : null,
      'submissionUrl': submissionUrl,
      'feedback': feedback,
    };
  }

  TaskModel copyWith({
    String? id,
    String? mentorId,
    String? studentId,
    String? mentorshipId,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? submittedAt,
    String? submissionUrl,
    String? feedback,
  }) {
    return TaskModel(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      studentId: studentId ?? this.studentId,
      mentorshipId: mentorshipId ?? this.mentorshipId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      submissionUrl: submissionUrl ?? this.submissionUrl,
      feedback: feedback ?? this.feedback,
    );
  }
}

// ✅ Alias de compatibilité : permet d'utiliser Task ou TaskModel dans les autres fichiers
// sans tout casser. À supprimer une fois tous les fichiers migrés.
typedef Task = TaskModel;
