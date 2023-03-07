import 'dart:developer';
import 'package:mynotes/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

const tag = "RegisterView";

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
              log("Clicked on Register Button\nEmail: ${_email.text} \nPassword: ${_password.text}",
                  name: tag);
              final email = _email.text;
              final password = _password.text;
              log("Registering user.........", name: tag);

              try {
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
                log("Registered user with email ${_email.text} \nUser credential is $userCredential",
                    name: tag);

                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                if (!mounted) return;
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on FirebaseAuthException catch (e) {
                log("Finished with FirebaseAuthException: ${e.code}",
                    name: tag);
                if (e.code == "weak-password") {
                  log("Weak password", name: tag);
                  await showErrorDialog(
                    context,
                    "Weak password",
                  );
                } else if (e.code == "email-already-in-use") {
                  log("Email is already in use", name: tag);
                  await showErrorDialog(
                    context,
                    "Email is already in use",
                  );
                } else if (e.code == "invalid-email") {
                  log("Invalid email", name: tag);
                  await showErrorDialog(
                    context,
                    "This is an invalid email address",
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
            child: const Text("Register"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Already registered? Login here!"))
        ],
      ),
    );
  }
}
