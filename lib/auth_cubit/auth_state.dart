abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthChanged extends AuthState {
  const AuthChanged();
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.message);
  final String message;
}
