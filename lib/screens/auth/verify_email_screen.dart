import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth_cubit/auth_cubit.dart';
import '../../auth_cubit/auth_state.dart';
import 'auth_widgets.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthScaffold(
        title: 'Verify your email',
        subtitle: 'We sent a verification link to your email address.',
        child: Column(
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 88,
              color: Color(0xFF2A5240),
            ),
            const SizedBox(height: 24),
            const Text(
              'Open the email, tap the link, then come back and refresh this screen.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => AuthButton(
                label: 'I verified my email',
                loading: state is AuthLoading,
                onPressed: () =>
                    context.read<AuthCubit>().refreshEmailVerification(),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  context.read<AuthCubit>().resendVerificationEmail(),
              child: const Text('Resend email'),
            ),
            TextButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: const Text('Use another account'),
            ),
          ],
        ),
      ),
    );
  }
}
