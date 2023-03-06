import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

const tag = "HomePage";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              log("Current user: ${user?.email}", name: tag);
              if (user != null) {
                if (user.emailVerified) {
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

 
