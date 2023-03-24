import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

String tag = "AuthBlock";

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(
          const AuthStateUninitialized(isLoading: true),
        ) {
    // send email authentication
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    // register
    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        log("Trying to register user.........", name: tag);
        try {
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
          log("Registered user with email: $email");
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );

    // initialize
    on<AuthEventIinitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });

    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingtext: "Please wait while you get logged in",
        ),
      );
      final email = event.email;
      final password = event.password;
      log("Logging in user.........", name: tag);
      try {
        final user = await provider.logIn(email: email, password: password);
        if (user.isEmailVerified) {
          log("User is verified\nLogged in user with email $email\n",
              name: tag);
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        } else {
          log("You need to verify your email first ", name: tag);
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });

    // log out
    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateUninitialized(isLoading: false));
        try {
          log("Starting to sign out.....", name: tag);
          await provider.logOut();
          log("User signed out", name: tag);
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    // should register
    on<AuthEventShouldRegister>(
      (event, emit) {
        emit(const AuthStateRegistering(exception: null, isLoading: false));
      },
    );

    // forgot password
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
            exception: null, hasSentEmail: false, isLoading: false));
        final email = event.email;
        if (email == null) {
          return; 
        }
        // user wantss to actually send a forgot password email
        emit(const AuthStateForgotPassword(
            exception: null, hasSentEmail: false, isLoading: true));

        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
          log("Exception here is $e");
        }

        emit(AuthStateForgotPassword(
            exception: exception,
            hasSentEmail: didSendEmail,
            isLoading: false));
      },
    );

    // on delete account
    on<AuthEventDeleteAccount>(
      (event, emit) async {
        try {
          log("Deleting user account", name: tag);
          final deleted = await provider.deleteAccount();
          if (deleted) {
            log("User deleted", name: tag);
          }
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (exception) {
          log("Delete account has error: ${exception.toString()}", name: tag);
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
      },
    );
  }
}
