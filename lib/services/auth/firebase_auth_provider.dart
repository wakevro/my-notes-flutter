import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

const tag = "FirebaseAuthProvider";

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        log("Weak password", name: tag);
        throw WeakPasswordAuthException();
      } else if (e.code == "email-already-in-use") {
        log("Email is already in use", name: tag);
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == "invalid-email") {
        log("Invalid email", name: tag);
        throw InvalidEmailAuthException();
      } else {
        log("Finished with error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
            name: tag);
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        log("User not found", name: tag);
        throw UserNotFoundAuthException();
      } else if (e.code == "wrong-password") {
        log("Wrong password", name: tag);
        throw WrongPasswordAuthException();
      } else {
        log("Finished with error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
            name: tag);
        throw GenericAuthException();
      }
    } catch (e) {
      log("Finished with error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
          name: tag);
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      log("Finished with error: ${e.code}\n", name: tag);
      switch (e.code) {
        case "missing-email":
          throw InvalidEmailAuthException();
        case "user-not-found":
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      log("Finished with generic error: ${e.toString()}\nRuntime type: ${e.runtimeType}",
          name: tag);
      throw GenericAuthException();
    }
  }
}
