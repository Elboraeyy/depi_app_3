import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/student_model.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance,
      super(const HomeState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _students {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('You must be signed in.');
    return _firestore.collection('users').doc(uid).collection('students');
  }

  Future<void> getStudentsFromServer() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final response = await _students.orderBy('name').get();
      emit(
        HomeState(
          status: HomeStatus.success,
          students: response.docs.map(StudentModel.fromDocument).toList(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: HomeStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> addStudent(StudentModel student) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _students.add(student.toMap());
      await getStudentsFromServer();
    } catch (error) {
      emit(
        state.copyWith(status: HomeStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> updateStudent(StudentModel student) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _students.doc(student.id).update(student.toMap());
      await getStudentsFromServer();
    } catch (error) {
      emit(
        state.copyWith(status: HomeStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> deleteStudent(String id) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      await _students.doc(id).delete();
      await getStudentsFromServer();
    } catch (error) {
      emit(
        state.copyWith(status: HomeStatus.failure, message: error.toString()),
      );
    }
  }
}
