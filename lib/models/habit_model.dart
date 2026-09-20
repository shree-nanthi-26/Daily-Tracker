import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String title;
  final String category;
  final String color;
  final int targetFrequency; // e.g. 7 for daily, 5 for weekdays, etc.
  final String? reminderTime; // e.g. '08:00 AM'
  final int sortOrder;
  final DateTime createdAt;

  const HabitModel({
    required this.id,
    required this.title,
    this.category = 'General',
    this.color = '#6366F1',
    this.targetFrequency = 7,
    this.reminderTime,
    this.sortOrder = 0,
    required this.createdAt,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    String? color,
    int? targetFrequency,
    String? reminderTime,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      color: color ?? this.color,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      reminderTime: reminderTime ?? this.reminderTime,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'color': color,
      'target_frequency': targetFrequency,
      'reminder_time': reminderTime,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final idVal = docId ?? json['id']?.toString() ?? '';

    DateTime created;
    if (json['created_at'] is Timestamp) {
      created = (json['created_at'] as Timestamp).toDate();
    } else if (json['created_at'] is String) {
      created = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return HabitModel(
      id: idVal,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      color: json['color'] as String? ?? '#6366F1',
      targetFrequency: (json['target_frequency'] as num?)?.toInt() ?? 7,
      reminderTime: json['reminder_time'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: created,
    );
  }

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HabitModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'color': color,
      'target_frequency': targetFrequency,
      'reminder_time': reminderTime,
      'sort_order': sortOrder,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
