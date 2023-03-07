import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

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
          const Text(
              "We've sent you an email verification. Please open it to verify your account"),
          const Text(
              "If you have not received a verification email yet, click the button below"),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                log("Trying to send verification email for ${user?.email} ..........",
                    name: tag);
                await user?.sendEmailVerification();
                log("Sent to ${user?.email}", name: tag);
                if (!mounted) return;
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Send verification email")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }
}
