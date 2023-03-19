import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/dimensions.dart';
import 'package:mynotes/constants/images.dart';
import 'package:mynotes/constants/pallete.dart';
import 'package:mynotes/constants/text_styling.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/bloc/auth_block.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: Dimension.bodyPadding,
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: phoneImage),
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Text(
                context.loc.verify_email_view_prompt,
                style: TStyle.bodyMedium,
              ),
              const SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: () async {
                  context.read<AuthBloc>().add(
                        const AuthEventSendEmailVerification(),
                      );
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
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
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.loc.verify_email_send_email_verification,
                          style: TStyle.bodyMedium.copyWith(
                              color: Pallete.whiteColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 60,
                padding:
                    const EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
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
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    },
                    child: Text(
                      context.loc.back_to_login,
                      style: TStyle.darkButton,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
