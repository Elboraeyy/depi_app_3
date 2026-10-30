import 'package:flutter_test/flutter_test.dart';

import 'package:depi_app/models/student_model.dart';
import 'package:depi_app/models/task_model.dart';

void main() {
  test('student model maps its fields', () {
    const student = StudentModel(name: 'Mona', age: '21', grade: 'A');
    expect(student.toMap()['name'], 'Mona');
    expect(student.toMap()['grade'], 'A');
  });

  test('task copyWith toggles completion without changing content', () {
    final task = TaskModel(
      title: 'Study Firebase',
      description: 'Review Firestore rules',
      dueDate: DateTime(2026, 11, 1),
    );
    final completed = task.copyWith(isCompleted: true);
    expect(completed.title, task.title);
    expect(completed.isCompleted, isTrue);
  });
}
