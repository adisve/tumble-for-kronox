import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/ui/main_app_widget/account_page/tumble_account_page.dart';
import 'package:tumble/core/ui/main_app_widget/cubit/main_app_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/main_app_bottom_nav_bar/cubit/bottom_nav_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/main_app_bottom_nav_bar/data/nav_bar_items.dart';
import 'package:tumble/core/ui/main_app_widget/main_app_bottom_nav_bar/tumble_navigation_bar.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/auth_cubit/auth_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/cubit/drawer_state.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/tumble_app_drawer.dart';
import 'package:tumble/core/ui/main_app_widget/schedule_view_widgets/tumble_calendar_view/tumble_calendar_view.dart';
import 'package:tumble/core/ui/main_app_widget/schedule_view_widgets/tumble_list_view/tumble_list_view.dart';
import 'package:tumble/core/ui/main_app_widget/schedule_view_widgets/tumble_week_view/tumble_week_view.dart';
import 'package:tumble/core/ui/main_app_widget/search_page_widgets/cubit/search_page_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/search_page_widgets/search/tumble_search_page.dart';

import 'misc/tumble_app_bar.dart';

class MainAppNavigationRootPage extends StatefulWidget {
  const MainAppNavigationRootPage({Key? key}) : super(key: key);

  @override
  State<MainAppNavigationRootPage> createState() =>
      _MainAppNavigationRootPageState();
}

class _MainAppNavigationRootPageState extends State<MainAppNavigationRootPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainAppCubit(),
      child: BlocProvider(
        create: (context) => MainAppNavigationCubit(),
        child: BlocBuilder<MainAppNavigationCubit, MainAppNavigationState>(
          builder: (context, navState) {
            return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.background,
                endDrawer: BlocProvider(
                  create: (context) => DrawerCubit(),
                  child: const TumbleAppDrawer(),
                ),
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                          value: BlocProvider.of<MainAppCubit>(context)),
                      BlocProvider.value(
                          value:
                              BlocProvider.of<MainAppNavigationCubit>(context))
                    ],
                    child: TumbleAppBar(
                      visibleBookmark: [1, 2, 3].contains(navState.index),
                      toggleFavorite: () async =>
                          await BlocProvider.of<MainAppCubit>(context)
                              .toggleFavorite(context),
                    ),
                  ),
                ),
                body: FutureBuilder(
                    future: BlocProvider.of<MainAppCubit>(context)
                        .initMainAppCubit(),
                    builder: (BuildContext context, _) {
                      switch (navState.navbarItem) {
                        case NavbarItem.SEARCH:
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppCubit>(context)),
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppNavigationCubit>(
                                            context)),
                                BlocProvider(
                                    create: (context) => SearchPageCubit())
                              ], child: const TumbleSearchPage()));
                        case NavbarItem.LIST:
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppCubit>(context)),
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppNavigationCubit>(
                                            context)),
                              ], child: const TumbleListView()));
                        case NavbarItem.WEEK:
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppCubit>(context)),
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppNavigationCubit>(
                                            context)),
                              ], child: const TumbleWeekView()));
                        case NavbarItem.CALENDAR:
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppCubit>(context)),
                                BlocProvider.value(
                                    value:
                                        BlocProvider.of<MainAppNavigationCubit>(
                                            context)),
                              ], child: const TumbleCalendarView()));
                        case NavbarItem.USER_ACCOUNT:
                          return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: MultiBlocProvider(providers: [
                                BlocProvider.value(
                                    value: BlocProvider.of<AuthCubit>(context)),
                              ], child: const TumbleAccountPage()));
                      }
                    }),
                bottomNavigationBar: TumbleNavigationBar(onTap: (index) {
                  BlocProvider.of<MainAppNavigationCubit>(context)
                      .getNavBarItem(NavbarItem.values[index]);
                }));
          },
        ),
      ),
    );
  }
}
