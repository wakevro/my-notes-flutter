import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const tag = "VerifyEmail";

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Column(
        children: [
          const Text("Please verify your email address: "),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                log("Trying to send verification email for ${user?.email} ..........",
                    name: tag);
                await user?.sendEmailVerification();
                log("Sent to ${user?.email}", name: tag);
              },
              child: const Text("Send verification email")),
        ],
      ),
    );
  }
}
