import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/images.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';

import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

import 'package:mynotes/utilities/dialog/error_dialog.dart';

const tag = "LoginView";

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  bool _isSecuredPassword = true;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
                context, context.loc.login_error_cannot_find_user);
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
                context, context.loc.login_error_wrong_credentials);
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, context.loc.login_error_auth_error);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Pallete.whiteColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: Dimension.bodyPadding,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: fallImage),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  context.loc.welcome_back,
                  style: TStyle.heading1,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 15, top: 5, right: 15, bottom: 5),
                  decoration: BoxDecoration(
                      color: Pallete.lightColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(138, 192, 210, 0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ]),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: context.loc.email_text_field_placeholder,
                      labelText: context.loc.email,
                      hintStyle: TStyle.placeholder,
                    ),
                    controller: _email,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    enableSuggestions: true,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  padding: const EdgeInsets.only(
                      left: 15, top: 5, right: 15, bottom: 5),
                  decoration: BoxDecoration(
                      color: Pallete.lightColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(138, 192, 210, 0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ]),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: context.loc.password_text_field_placeholder,
                      labelText: context.loc.password,
                      hintStyle: TStyle.placeholder,
                      suffixIcon: togglePassword(),
                    ),
                    controller: _password,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isSecuredPassword,
                    enableSuggestions: false,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventForgotPassword());
                    },
                    child: Text(
                      context.loc.forgot_password,
                      style: TStyle.accentButton,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          log("Clicked on Login Button\nEmail: ${_email.text} \nPassword: ${_password.text}",
                              name: tag);
                          final email = _email.text;
                          final password = _password.text;
                          context.read<AuthBloc>().add(AuthEventLogIn(
                                email: email,
                                password: password,
                              ));
                        },
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.only(
                              left: 15, top: 5, right: 15, bottom: 5),
                          decoration: BoxDecoration(
                            color: Pallete.darkColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(138, 192, 210, 0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 5)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.loc.login,
                                style: TStyle.lightButton,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.adaptive.arrow_forward,
                                color: Pallete.whiteColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.only(
                            left: 0, top: 5, right: 0, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromRGBO(138, 192, 210, 0.3),
                                blurRadius: 10,
                                offset: Offset(0, 1)),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              side: const BorderSide(
                                  width: 2, color: Pallete.accentColor),
                            ),
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthEventShouldRegister());
                            },
                            child: Text(
                              context.loc.login_view_not_registered_yet,
                              style: TStyle.darkButton,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconButton togglePassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isSecuredPassword = !_isSecuredPassword;
        });
      },
      icon: _isSecuredPassword
          ? const Icon(Icons.visibility_off_sharp)
          : const Icon(Icons.visibility_sharp),
    );
  }
}
