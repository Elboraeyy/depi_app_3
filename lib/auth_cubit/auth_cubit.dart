import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(const AuthInitial());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Unable to create account.');

      await user.updateDisplayName(name.trim());
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await user.sendEmailVerification();
      emit(const AuthSuccess('Account created. Check your email to continue.'));
      emit(const AuthChanged());
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(_authMessage(error)));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _auth.currentUser?.reload();
      emit(const AuthChanged());
    } on FirebaseAuthException catch (error) {
      emit(AuthFailure(_authMessage(error)));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    emit(const AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Please sign in first.');
      await user.sendEmailVerification();
      emit(const AuthSuccess('Verification email sent.'));
      emit(const AuthChanged());
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> refreshEmailVerification() async {
    emit(const AuthLoading());
    try {
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified == true) {
        emit(const AuthChanged());
      } else {
        emit(const AuthFailure('Your email is not verified yet.'));
      }
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    emit(const AuthChanged());
  }

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'wrong-password':
        return 'The password is incorrect.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
