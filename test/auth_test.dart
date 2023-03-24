import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    "Mock Authentication",
    () {
      final provider = MockAuthProvider();
      test(
        "Should not be initialized to begin with",
        () {
          expect(provider._isInitialized, false);
        },
      );

      test(
        "Cannot log out if not initialized",
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
        },
      );

      test(
        "Should be able to initialized",
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
      );

      test(
        "User should be null after initialization",
        () async {
          expect(provider.currentUser, null);
        },
      );

      test(
        "Should be able to initialize in less than 2 seconds",
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(Duration(seconds: 2)),
      );

      test(
        "Create user should delegate to logIn function",
        () async {
          final badEmailUser = provider.createUser(
            email: "wronguser@test.com",
            password: "password",
          );

          expect(badEmailUser,
              throwsA(const TypeMatcher<UserNotFoundAuthException>()));

          final badPasswordUser = provider.createUser(
            email: "correctuser@test.com",
            password: "wrongpassword",
          );
          expect(badPasswordUser,
              throwsA(const TypeMatcher<WrongPasswordAuthException>()));

          final user = await provider.createUser(
            email: "correctuser@test.com",
            password: "rightpassword",
          );
          expect(provider.currentUser, user);
          expect(user.isEmailVerified, false);
        },
      );

      test(
        "Logged in user should be able to get verified",
        () {
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(user!.isEmailVerified, true);
        },
      );

      test(
        "Should be able to log out and log in again",
        () async {
          await provider.logOut();
          await provider.logIn(
            email: "correctuser@test.com",
            password: "rightpassword",
          );
          final user = provider.currentUser;
          expect(user, isNotNull);
        },
      );

      test(
        "Should be able to send password reset",
        () async {
          expect(
            provider.sendPasswordReset(toEmail: "invalidemail"),
            throwsA(const TypeMatcher<InvalidEmailAuthException>()),
          );

          expect(provider.sendPasswordReset(toEmail: "usernotfound"),
              throwsA(const TypeMatcher<UserNotFoundAuthException>()));
        },
      );

      test(
        "Should be able to delete account",
        () async {
          final result = provider.deleteAccount();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(result, isA<Future<bool>>());
        },
      );
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == "wronguser@test.com") throw UserNotFoundAuthException();
    if (password == "wrongpassword") throw WrongPasswordAuthException();
    const user = AuthUser(
      email: "correctuser@test.com",
      isEmailVerified: false,
      id: "my_id",
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    const newUser = AuthUser(
      email: "correctuser@test.com",
      isEmailVerified: true,
      id: "my_id",
    );
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    if (!isInitialized) throw NotInitializedException();
    if (toEmail == "invalidemail") throw InvalidEmailAuthException();
    if (toEmail == "usernotfound") throw UserNotFoundAuthException();
  }

  @override
  Future<bool> deleteAccount() {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    return Future.value(true);
  }
}
