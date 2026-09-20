import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final double targetValue;
  final double currentValue;
  final String unit;
  final String period; // 'daily' | 'weekly' | 'monthly'
  final String? deadline;
  final String? category; // 'Work' | 'Health' | 'Personal' | 'Learning' | 'All'
  final String linkedType; // 'all' | 'tasks' | 'habits' | 'manual'
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.title,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.unit,
    this.period = 'weekly',
    this.deadline,
    this.category,
    this.linkedType = 'all',
    required this.createdAt,
  });

  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    final pct = (currentValue / targetValue) * 100;
    return pct > 100 ? 100.0 : (pct < 0 ? 0.0 : pct);
  }

  bool get isAchieved => currentValue >= targetValue && targetValue > 0;

  GoalModel copyWith({
    String? id,
    String? title,
    double? targetValue,
    double? currentValue,
    String? unit,
    String? period,
    String? deadline,
    String? category,
    String? linkedType,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      period: period ?? this.period,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      linkedType: linkedType ?? this.linkedType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'period': period,
      'deadline': deadline,
      'category': category,
      'linked_type': linkedType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final idVal = docId ?? json['id']?.toString() ?? '';

    DateTime created;
    if (json['created_at'] is Timestamp) {
      created = (json['created_at'] as Timestamp).toDate();
    } else if (json['created_at'] is String) {
      created = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return GoalModel(
      id: idVal,
      title: json['title'] as String? ?? '',
      targetValue: (json['target_value'] as num?)?.toDouble() ?? 10.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'hours',
      period: json['period'] as String? ?? 'weekly',
      deadline: json['deadline'] as String?,
      category: json['category'] as String?,
      linkedType: json['linked_type'] as String? ?? 'all',
      createdAt: created,
    );
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GoalModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'period': period,
      'deadline': deadline,
      'category': category,
      'linked_type': linkedType,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
