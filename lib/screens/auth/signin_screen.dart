import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth_cubit/auth_cubit.dart';
import '../../auth_cubit/auth_state.dart';
import 'auth_widgets.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Sign in to manage your DEPI workspace.',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: validEmail,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => requiredValue(value, 'Password'),
              ),
              const SizedBox(height: 22),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) => AuthButton(
                  label: 'Sign in',
                  loading: state is AuthLoading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<AuthCubit>().signIn(
                      email: _email.text,
                      password: _password.text,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text('Create a new account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
