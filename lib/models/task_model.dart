import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  const TaskModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? createdAt;

  factory TaskModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    final dueTimestamp = data['dueDate'] as Timestamp?;
    final createdTimestamp = data['createdAt'] as Timestamp?;
    return TaskModel(
      id: document.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dueDate: dueTimestamp?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: createdTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = false}) => {
    'title': title,
    'description': description,
    'dueDate': Timestamp.fromDate(dueDate),
    'isCompleted': isCompleted,
    if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
  };

  TaskModel copyWith({bool? isCompleted}) => TaskModel(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
  );
}
