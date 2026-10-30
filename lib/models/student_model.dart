import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  const StudentModel({
    this.id = '',
    required this.name,
    required this.age,
    required this.grade,
  });

  final String id;
  final String name;
  final String age;
  final String grade;

  factory StudentModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return StudentModel(
      id: document.id,
      name: data['name'] as String? ?? '',
      age: data['age'] as String? ?? '',
      grade: data['grade'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'grade': grade,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
