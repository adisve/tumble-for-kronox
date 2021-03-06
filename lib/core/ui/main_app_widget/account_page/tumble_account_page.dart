import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/authenticated_page.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/unauthenticated_page.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/auth_cubit/auth_cubit.dart';

class TumbleAccountPage extends StatefulWidget {
  const TumbleAccountPage({Key? key}) : super(key: key);

  @override
  State<TumbleAccountPage> createState() => _TumbleAccountPageState();
}

class _TumbleAccountPageState extends State<TumbleAccountPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
            switch (state.status) {
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
          }),
        ),
      ),
    );
  }
}
