import 'dart:developer';
import 'package:mynotes/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

const tag = "LoginView";

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email here",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your password here",
            ),
          ),
          TextButton(
            onPressed: () async {
              log("Clicked on Login Button\nEmail: ${_email.text} \nPassword: ${_password.text}",
                  name: tag);
              final email = _email.text;
              final password = _password.text;
              log("Logging in user.........", name: tag);
              try {
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
                log("Logged in user with email ${_email.text} \nUser credential is $userCredential",
                    name: tag);
                if (!mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                log("Finished with FirebaseAuthException: ${e.code}",
                    name: tag);
                if (e.code == "user-not-found") {
                  log("User not found", name: tag);
                  await showErrorDialog(
                    context,
                    "User not found",
                  );
                } else if (e.code == "wrong-password") {
                  log("Wrong password", name: tag);
                  await showErrorDialog(
                    context,
                    "Wrong password",
                  );
                } else {
                  log("Finished with error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
                      name: tag);
                  await showErrorDialog(
                    context,
                    "Error: ${e.code}",
                  );
                }
              } on Exception catch (e) {
                log("Finished with error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
                    name: tag);
                await showErrorDialog(
                  context,
                  "Error: ${e.toString()}",
                );
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text("Not registered yet? Register here"),
          ),
        ],
      ),
    );
  }
}
