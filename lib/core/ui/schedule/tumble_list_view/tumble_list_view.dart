import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/core/api/apiservices/runtime_error_type.dart';
import 'package:tumble/core/navigation/app_navigator.dart';
import 'package:tumble/core/ui/bottom_nav_bar/cubit/bottom_nav_cubit.dart';
import 'package:tumble/core/ui/bottom_nav_bar/data/nav_bar_items.dart';
import 'package:tumble/core/ui/main_app/cubit/main_app_cubit.dart';
import 'package:tumble/core/ui/main_app/main_app.dart';
import 'package:tumble/core/ui/schedule/no_schedule.dart';
import 'package:tumble/core/ui/schedule/tumble_list_view/data/cupertino_alerts.dart';
import 'package:tumble/core/ui/schedule/tumble_list_view/data/to_top_button.dart';
import 'tumble_list_view_day_container.dart';

class TumbleListView extends StatelessWidget {
  const TumbleListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppNavigator navigator = BlocProvider.of<AppNavigator>(context);
    return BlocBuilder<MainAppCubit, MainAppState>(
      builder: (context, state) {
        switch (state.status) {
          case MainAppStatus.INITIAL:
            return NoScheduleAvailable(
              cupertinoAlertDialog: CustomAlertDialog.noBookMarkedSchedules(
                  context,
                  () => context
                      .read<MainAppNavigationCubit>()
                      .getNavBarItem(NavbarItem.SEARCH),
                  navigator),
              errorType: RuntimeErrorType.noCachedSchedule(),
            );
          case MainAppStatus.LOADING:
            return SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary);
          case MainAppStatus.POPULATED_VIEW:
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<MainAppCubit>().setLoading();
                    await context.read<MainAppCubit>().forceRefreshAll();
                  },
                  child: SingleChildScrollView(
                    controller: context.read<MainAppCubit>().controller,
                    child: Column(
                        children: state.listOfDays!
                            .where((day) =>
                                day.events.isNotEmpty &&
                                day.isoString.isAfter(DateTime.now()
                                    .subtract(const Duration(days: 1))))
                            .map((day) => TumbleListViewDayContainer(
                                  day: day,
                                  mainAppCubit:
                                      BlocProvider.of<MainAppCubit>(context),
                                ))
                            .toList()),
                  ),
                ),
                AnimatedPositioned(
                  bottom: 30,
                  right: context.read<MainAppCubit>().toTopButtonVisible()
                      ? 35
                      : -60,
                  duration: const Duration(milliseconds: 200),
                  child: ToTopButton(
                      scrollToTop: () =>
                          context.read<MainAppCubit>().scrollToTop()),
                ),
              ],
            );
          case MainAppStatus.FETCH_ERROR:
            return NoScheduleAvailable(
              errorType: state.message!,
              cupertinoAlertDialog: CustomAlertDialog.fetchError(
                  context,
                  () => context
                      .read<MainAppNavigationCubit>()
                      .getNavBarItem(NavbarItem.SEARCH),
                  navigator),
            );

          case MainAppStatus.EMPTY_SCHEDULE:
            return NoScheduleAvailable(
              errorType: RuntimeErrorType.emptyScheduleError(),
              cupertinoAlertDialog: CustomAlertDialog.previewContainsNoViews(
                  context,
                  () => context
                      .read<MainAppNavigationCubit>()
                      .getNavBarItem(NavbarItem.SEARCH),
                  navigator),
            );

          case MainAppStatus.NO_VIEW:
            return NoScheduleAvailable(
              errorType: RuntimeErrorType.noBookmarks(),
              cupertinoAlertDialog: CustomAlertDialog.noBookMarkedSchedules(
                  context,
                  () => context
                      .read<MainAppNavigationCubit>()
                      .getNavBarItem(NavbarItem.SEARCH),
                  navigator),
            );
        }
      },
    );
  }
}
