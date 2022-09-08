import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/theme/data/colors.dart';
import 'package:tumble/core/ui/account/events/user_event_list.dart';
import 'package:tumble/core/ui/account/user/user_account_info.dart';
import 'package:tumble/core/ui/login/cubit/auth_cubit.dart';

class AuthenticatedPage extends StatefulWidget {
  const AuthenticatedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AuthenticatedPage();
}

class _AuthenticatedPage extends State<AuthenticatedPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Column(
      children: [
        TabBar(
            controller: tabController,
            indicatorColor: CustomColors.orangePrimary,
            labelStyle: const TextStyle(fontSize: 17),
            labelColor: Theme.of(context).colorScheme.onBackground,
            tabs: const [
              Tab(
                icon: Icon(
                  CupertinoIcons.person,
                  size: 25,
                ),
              ),
              Tab(
                icon: Icon(
                  CupertinoIcons.news,
                  size: 25,
                ),
              )
            ]),
        Expanded(
          child: SizedBox(
            width: double.maxFinite,
            child: TabBarView(controller: tabController, children: [
              BlocProvider.value(
                value: BlocProvider.of<AuthCubit>(context),
                child: const UserAccountInfo(),
              ),
              BlocProvider.value(
                value: BlocProvider.of<AuthCubit>(context),
                child: const Events(),
              ),
            ]),
          ),
        )
      ],
    );
  }
}