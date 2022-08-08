import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/core/ui/account/authenticated_page.dart';
import 'package:tumble/core/ui/account/unauthenticated_page.dart';
import 'package:tumble/core/ui/login/cubit/auth_cubit.dart';

class TumbleAccountPage extends StatefulWidget {
  const TumbleAccountPage({Key? key}) : super(key: key);

  @override
  State<TumbleAccountPage> createState() => _TumbleAccountPageState();
}

class _TumbleAccountPageState extends State<TumbleAccountPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      switch (state.authStatus) {
        case AuthStatus.AUTHENTICATED:
          return BlocProvider.value(
            value: BlocProvider.of<AuthCubit>(context),
            child: const AuthenticatedPage(),
          );
        case AuthStatus.UNAUTHENTICATED:
          return const UnauthenticatedPage();
        default:
          return SpinKitThreeBounce(
              color: Theme.of(context).colorScheme.primary);
      }
    });
  }
}