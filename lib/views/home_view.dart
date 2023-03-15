import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/show_circular_loading.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

const tag = "HomePage";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventIinitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          log("You are verified", name: tag);
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          log("You need to verify your email first ", name: tag);
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          log("User is null", name: tag);
          return const LoginView();
        } else {
          return showCircularLoading();
        }
      },
    );
  }
}
