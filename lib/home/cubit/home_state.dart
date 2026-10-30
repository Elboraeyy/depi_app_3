import '../../models/student_model.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.students = const [],
    this.message,
  });

  final HomeStatus status;
  final List<StudentModel> students;
  final String? message;

  HomeState copyWith({
    HomeStatus? status,
    List<StudentModel>? students,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      students: students ?? this.students,
      message: message,
    );
  }
}
