import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/user_event_list/cubit/user_event_list_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/user_event_list/user_event_list.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/user_info.dart';
import 'package:tumble/core/ui/main_app_widget/login_page/cubit/login_page_state.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/auth_cubit/auth_cubit.dart';

class AuthenticatedPage extends StatelessWidget {
  const AuthenticatedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserInfo(
          name: BlocProvider.of<AuthCubit>(context).state.userSession!.name,
          loggedIn: true,
          onPressed: () {
            BlocProvider.of<AuthCubit>(context).logout();
            /* BlocProvider.of<LoginPageCubit>(context).emitCleanInitState(); */
          },
        ),
        const SizedBox(
          height: 60,
        ),
        MultiBlocProvider(providers: [
          BlocProvider.value(
            value: BlocProvider.of<AuthCubit>(context),
          ),
          BlocProvider(
            create: (context) => UserEventListCubit(),
          )
        ], child: const UserEventList())
      ],
    );
  }
}
