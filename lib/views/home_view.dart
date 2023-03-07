import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

const tag = "HomePage";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              log("Current user: ${user?.email}", name: tag);
              if (user != null) {
                if (user.isEmailVerified) {
                  log("You are verified", name: tag);

                  return const NotesView();
                } else {
                  log("You need to verify your email first ", name: tag);
                  return const VerifyEmailView();
                }
              } else {
                log("User is null", name: tag);
                return const LoginView();
              }
            default:
              return Scaffold(
                appBar: AppBar(title: const Text("Home")),
                body: const Center(child: CircularProgressIndicator()),
              );
          }
        });
  }
}
