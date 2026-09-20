import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String text;
  final bool done;
  final String priority; // 'High' | 'Medium' | 'Low'
  final String? dueDate; // 'YYYY-MM-DD'
  final String? category;
  final String? notes;
  final DateTime? completedAt;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.text,
    this.done = false,
    this.priority = 'Medium',
    this.dueDate,
    this.category = 'General',
    this.notes,
    this.completedAt,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? text,
    bool? done,
    String? priority,
    String? dueDate,
    String? category,
    String? notes,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'done': done,
      'priority': priority,
      'due_date': dueDate,
      'category': category,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final idVal = docId ?? json['id']?.toString() ?? '';
    final rawDone = json['done'];
    final bool isDone = rawDone == true || rawDone == 1 || rawDone == 'true';

    DateTime created;
    if (json['created_at'] is Timestamp) {
      created = (json['created_at'] as Timestamp).toDate();
    } else if (json['created_at'] is String) {
      created = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    DateTime? completed;
    if (json['completed_at'] is Timestamp) {
      completed = (json['completed_at'] as Timestamp).toDate();
    } else if (json['completed_at'] is String) {
      completed = DateTime.tryParse(json['completed_at']);
    }

    return TaskModel(
      id: idVal,
      text: json['text'] as String? ?? '',
      done: isDone,
      priority: json['priority'] as String? ?? 'Medium',
      dueDate: json['due_date'] as String?,
      category: json['category'] as String? ?? 'General',
      notes: json['notes'] as String?,
      completedAt: completed,
      createdAt: created,
    );
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TaskModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'done': done,
      'priority': priority,
      'due_date': dueDate,
      'category': category,
      'notes': notes,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
