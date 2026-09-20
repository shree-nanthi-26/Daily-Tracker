import 'package:cloud_firestore/cloud_firestore.dart';

class HabitCompletionModel {
  final String id;
  final String habitId;
  final String dateStr; // 'YYYY-MM-DD'
  final DateTime completedAt;

  const HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.dateStr,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date_str': dateStr,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final idVal = docId ?? json['id']?.toString() ?? '';

    DateTime completed;
    if (json['completed_at'] is Timestamp) {
      completed = (json['completed_at'] as Timestamp).toDate();
    } else if (json['completed_at'] is String) {
      completed = DateTime.tryParse(json['completed_at']) ?? DateTime.now();
    } else {
      completed = DateTime.now();
    }

    return HabitCompletionModel(
      id: idVal,
      habitId: json['habit_id']?.toString() ?? '',
      dateStr: json['date_str']?.toString() ?? '',
      completedAt: completed,
    );
  }

  factory HabitCompletionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return HabitCompletionModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'habit_id': habitId,
      'date_str': dateStr,
      'completed_at': Timestamp.fromDate(completedAt),
    };
  }
}
