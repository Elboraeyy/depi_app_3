import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/task_model.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance,
      super(const TasksState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tasks {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('You must be signed in.');
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final response = await _tasks
          .orderBy('createdAt', descending: true)
          .get();
      emit(
        TasksState(
          status: TasksStatus.success,
          tasks: response.docs.map(TaskModel.fromDocument).toList(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: TasksStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> addTask(TaskModel task) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      await _tasks.add(task.toMap(includeCreatedAt: true));
      await loadTasks();
    } catch (error) {
      emit(
        state.copyWith(status: TasksStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> updateTask(TaskModel task) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      await _tasks.doc(task.id).update(task.toMap());
      await loadTasks();
    } catch (error) {
      emit(
        state.copyWith(status: TasksStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> toggleTask(TaskModel task) =>
      updateTask(task.copyWith(isCompleted: !task.isCompleted));

  Future<void> deleteTask(String id) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      await _tasks.doc(id).delete();
      await loadTasks();
    } catch (error) {
      emit(
        state.copyWith(status: TasksStatus.failure, message: error.toString()),
      );
    }
  }
}
