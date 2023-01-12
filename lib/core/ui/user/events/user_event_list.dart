import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/ui/cubit/user_event_cubit.dart';
import 'package:tumble/core/ui/data/string_constants.dart';
import 'package:tumble/core/ui/schedule/dynamic_error_page.dart';
import 'package:tumble/core/ui/tumble_loading.dart';
import 'package:tumble/core/ui/user/events/user_event_section.dart';

class Events extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const Events({Key? key, required this.onRefresh}) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserEventCubit, UserEventState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 10),
                    child: Text(
                      S.userEvents.availableEvents(),
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Builder(
                      builder: (context) {
                        switch (state.userEventListStatus) {
                          case UserOverviewStatus.loading:
                            return const Center(child: TumbleLoading());
                          case UserOverviewStatus.loaded:
                            return _loaded(context, state);
                          case UserOverviewStatus.error:
                            return DynamicErrorPage(
                              errorType: S.userEvents.failedToLoad(),
                              toSearch: false,
                              description: '',
                            );
                          case UserOverviewStatus.initial:
                            return DynamicErrorPage(
                              errorType: S.userEvents.empty(),
                              toSearch: false,
                              description: '',
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _loaded(BuildContext context, UserEventState state) {
  final userHasNoEvents = state.userEvents!.registeredEvents.isEmpty &&
      state.userEvents!.unregisteredEvents.isEmpty &&
      state.userEvents!.upcomingEvents.isEmpty;

  return userHasNoEvents
      ? Align(
          alignment: Alignment.center,
          child: Text(
            S.userEvents.empty(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              letterSpacing: 0.5,
            ),
          ),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            state.userEvents!.unregisteredEvents.isEmpty
                ? Container()
                : UserEventSection(
                    sectionTitle: S.userEvents.needToSignup(),
                    availableEvents: state.userEvents!.unregisteredEvents,
                    upcomingEvents: null,
                  ),
            state.userEvents!.registeredEvents.isEmpty
                ? Container()
                : UserEventSection(
                    sectionTitle: S.userEvents.alreadySignedUp(),
                    availableEvents: state.userEvents!.registeredEvents,
                    upcomingEvents: null,
                  ),
            state.userEvents!.upcomingEvents.isEmpty
                ? Container()
                : UserEventSection(
                    sectionTitle: S.userEvents.upcoming(),
                    availableEvents: null,
                    upcomingEvents: state.userEvents!.upcomingEvents,
                  )
          ],
        );
}
