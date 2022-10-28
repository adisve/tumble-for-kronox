import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tumble/core/api/backend/repository/cache_repository.dart';
import 'package:tumble/core/api/backend/response_types/schedule_or_programme_response.dart';
import 'package:tumble/core/api/database/data/access_stores.dart';
import 'package:tumble/core/api/database/repository/database_repository.dart';
import 'package:tumble/core/api/dependency_injection/get_it.dart';
import 'package:tumble/core/api/notifications/builders/notification_service_builder.dart';
import 'package:tumble/core/api/notifications/repository/notification_repository.dart';
import 'package:tumble/core/api/preferences/repository/preference_repository.dart';
import 'package:tumble/core/extensions/extensions.dart';
import 'package:tumble/core/models/backend_models/schedule_model.dart';
import 'package:tumble/core/models/ui_models/week_model.dart';
import 'package:tumble/core/theme/color_picker.dart';
import 'package:tumble/core/ui/data/string_constants.dart';
import 'package:tumble/core/ui/scaffold_message.dart';

part 'schedule_view_state.dart';

class ScheduleViewCubit extends Cubit<ScheduleViewState> {
  ScheduleViewCubit()
      : super(const ScheduleViewState(
            status: ScheduleViewStatus.LOADING,
            listOfDays: null,
            listOfWeeks: null,
            listViewToTopButtonVisible: false,
            message: null,
            listOfScheduleModels: [])) {
    _init();
  }

  final _cacheAndInteractionService = getIt<CacheRepository>();
  final _notificationBuilder = NotificationServiceBuilder();
  final _notificationService = getIt<NotificationRepository>();
  final _databaseService = getIt<DatabaseRepository>();
  final _preferenceService = getIt<PreferenceRepository>();
  final ScrollController _listViewScrollController = ScrollController();

  ScrollController get controller => _listViewScrollController;
  bool get hasBookMarkedSchedules => getIt<PreferenceRepository>().bookmarkIds!.isNotEmpty;
  bool get notificationCheck => getIt<PreferenceRepository>().allowedNotifications == null;
  bool get toTopButtonVisible =>
      _listViewScrollController.hasClients ? _listViewScrollController.offset >= 1000 : false;

  Future<void> _init() async {
    log(name: 'schedule_view_cubit', 'Fetching cache ...');
    await getCachedSchedules();
    _listViewScrollController.addListener((setScrollController));
  }

  @override
  Future<void> close() {
    _listViewScrollController.dispose();
    return super.close();
  }

  Future<void> getCachedSchedules() async {
    final currentScheduleIds = _preferenceService.bookmarkIds;
    List<List<Day>> matrixListOfDays = [];
    List<ScheduleModel> listOfScheduleModels = [];
    if (currentScheduleIds != null) {
      for (String? scheduleId in currentScheduleIds) {
        final bool userHasBookmarks = _preferenceService.userHasBookmarks;

        final bool? toggledToBeVisible = _preferenceService.bookmarkVisible(scheduleId);

        if (scheduleId != null && userHasBookmarks) {
          if (toggledToBeVisible != null && toggledToBeVisible) {
            log('Updating schedule');
            final ScheduleOrProgrammeResponse apiResponse = await _cacheAndInteractionService.findSchedule(scheduleId);

            switch (apiResponse.status) {
              case ScheduleOrProgrammeStatus.FETCHED:
                ScheduleModel newScheduleModel = apiResponse.data;
                if (newScheduleModel.isNotPhonySchedule()) {
                  final oldScheduleModel = await _databaseService.getOneSchedule(scheduleId);

                  List<Day> newListOfDays = _buildListOfDays(oldScheduleModel!, newScheduleModel);
                  matrixListOfDays.add(newListOfDays);
                  _databaseService.update(
                      ScheduleModel(cachedAt: newScheduleModel.cachedAt, id: newScheduleModel.id, days: newListOfDays));
                  listOfScheduleModels.add(
                      ScheduleModel(cachedAt: newScheduleModel.cachedAt, id: newScheduleModel.id, days: newListOfDays));
                }
                break;
              case ScheduleOrProgrammeStatus.CACHED:

                /// If schedule is retrieved from cache then all course
                /// colors will be available and no mapping will be done
                ScheduleModel currentScheduleModel = apiResponse.data;
                if (currentScheduleModel.isNotPhonySchedule()) {
                  matrixListOfDays.add(currentScheduleModel.days);
                  listOfScheduleModels.add(currentScheduleModel);
                }
                break;
              case ScheduleOrProgrammeStatus.ERROR:

                /// If an error occurs here, the schedule is empty currently
                /// and can be temporarily removed from the database for this session.
                //await _databaseService.remove(scheduleId, AccessStores.SCHEDULE_STORE);
                log(
                    name: 'schedule_view_cubit',
                    'Error in retrieveing schedule cache ..\nError on schedule: [$scheduleId');
                return;
              default:
                log(name: 'schedule_view_cubit', 'Unknown communication error occured on schedule: [$scheduleId]..');
                break;
            }
          }
        } else {
          emit(state.copyWith(status: ScheduleViewStatus.NO_VIEW));
        }
      }
      _setScheduleView(matrixListOfDays, listOfScheduleModels);
    }
  }

  void _setScheduleView(List<List<Day>> matrixListOfDays, List<ScheduleModel> listOfScheduleModels) {
    if (listOfScheduleModels.isNotEmpty) {
      final flattened = matrixListOfDays.expand((listOfDays) => listOfDays).toList();
      flattened.sort((prevDay, nextDay) => prevDay.isoString.compareTo(nextDay.isoString));

      var seen = <String>{};

      final listOfDays = groupBy(flattened, (Day day) => day.date)
          .entries
          .map((dayGrouper) => Day(
              name: dayGrouper.value[0].name,
              date: dayGrouper.value[0].date,
              isoString: dayGrouper.value[0].isoString,
              weekNumber: dayGrouper.value[0].weekNumber,
              events: dayGrouper.value.expand((day) => day.events).where((event) => seen.add(event.id)).toList()
                ..sort(((a, b) => a.from.compareTo(b.from)))))
          .toList();

      emit(state.copyWith(
          status: ScheduleViewStatus.POPULATED_VIEW,
          listOfDays: listOfDays,
          listOfWeeks: listOfDays.splitToWeek(),
          listOfScheduleModels: listOfScheduleModels));
      log(name: 'schedule_view_cubit', 'Successfully updated entire schedule view. Exiting ..');
    } else {
      emit(state.copyWith(status: ScheduleViewStatus.NO_VIEW));
    }
  }

  setScrollController() async {
    if (_listViewScrollController.offset >= 1000) {
      emit(state.copyWith(listViewToTopButtonVisible: true));
    } else {
      emit(state.copyWith(listViewToTopButtonVisible: false));
    }
  }

  void scrollToTop() {
    _listViewScrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  setLoading() {
    emit(state.copyWith(status: ScheduleViewStatus.LOADING));
  }

  Future<bool> createNotificationForEvent(Event inputEvent, BuildContext context) {
    return _notificationService.allowedNotifications().then((isAllowed) async {
      if (isAllowed) {
        final List<ScheduleModel> allSchedules = await _databaseService.getAll();
        final String channelKey = allSchedules
            .firstWhere((scheduleModel) => scheduleModel.days
                .expand((days) => days.events)
                .map((event) => event.course.id)
                .contains(inputEvent.course.id))
            .id;

        _notificationBuilder.buildOffsetNotification(
            id: inputEvent.id.encodeUniqueIdentifier(),
            channelKey: channelKey,
            groupkey: inputEvent.course.id,
            title: inputEvent.title.capitalize(),
            body: inputEvent.course.englishName,
            date: inputEvent.from);

        log(name: 'schedule_view_cubit', 'Created notification for event "${inputEvent.title.capitalize()}"');
        return true;
      }
      log(name: 'schedule_view_cubit', 'No new notifications created. User not allowed');
      return false;
    });
  }

  Future<List<dynamic>> createNotificationForCourse(Event inputEvent, BuildContext context) async {
    return _notificationService.allowedNotifications().then((isAllowed) async {
      if (isAllowed) {
        final List<ScheduleModel> allSchedules = await _databaseService.getAll();

        List<Event> events = allSchedules
            .map((scheduleModel) => scheduleModel.days)
            .expand((listOfDays) =>
                listOfDays.expand((day) => day.events.where((event) => event.course.id == inputEvent.course.id)))
            .toList();
        final String channelKey = allSchedules
            .firstWhere((scheduleModel) =>
                scheduleModel.days.expand((days) => days.events).map((event) => event.id).contains(inputEvent.id))
            .id;
        int successfullyCreatedNotifications = 0;
        for (Event event in events) {
          if (event.from.isAfter(DateTime.now())) {
            _notificationBuilder.buildOffsetNotification(
                id: event.id.encodeUniqueIdentifier(),
                channelKey: channelKey,
                groupkey: event.course.id,
                title: event.title,
                body: event.course.englishName,
                date: event.from);
            successfullyCreatedNotifications++;
          }
        }
        log(
            name: 'schedule_view_cubit',
            'Created $successfullyCreatedNotifications new notifications for ${inputEvent.course}');

        return [true, successfullyCreatedNotifications];
      }
      log(name: 'schedule_view_cubit', 'No new notifications created. Not allowed');
      return [false, 0];
    });
  }

  Future<bool> checkIfNotificationIsSetForEvent(Event event) => _notificationService.eventHasNotification(event);

  /// Returns true if course id is found in current list of notifications
  Future<bool> checkIfNotificationIsSetForCourse(Event event) => _notificationService.courseHasNotifications(event);

  Future<bool> cancelEventNotification(Event event) async {
    await _notificationService.cancelEventNotification(event);
    return !await checkIfNotificationIsSetForEvent(event);
  }

  /// Returns true if notification is still set for course
  Future<bool> cancelCourseNotifications(Event event) async {
    _notificationService.cancelCourseNotifications(event);
    return await checkIfNotificationIsSetForCourse(event);
  }

  void changeCourseColor(BuildContext context, Course course, Color color) async {
    ScheduleModel scheduleModel = state.listOfScheduleModels!.firstWhere((scheduleModel) =>
        scheduleModel.days.expand((days) => days.events).map((event) => event.course.id).contains(course.id));
    log(scheduleModel.days.toString());
    await _databaseService
        .update(ScheduleModel(
            cachedAt: scheduleModel.cachedAt,
            id: scheduleModel.id,
            days: scheduleModel.days
                .map((day) => Day(
                    name: day.name,
                    date: day.date,
                    isoString: day.isoString,
                    weekNumber: day.weekNumber,
                    events: day.events
                        .map((event) => Event(
                            id: event.id,
                            title: event.title,
                            course: () {
                              if (event.course.id == course.id) {
                                log('Old course color: ${event.course.courseColor}');
                                log('Input course color ${color.value}');
                                return Course(
                                    id: event.course.id,
                                    swedishName: event.course.swedishName,
                                    englishName: event.course.englishName,
                                    courseColor: color.value);
                              }
                              return event.course;
                            }(),
                            from: event.from,
                            to: event.to,
                            locations: event.locations,
                            teachers: event.teachers,
                            isSpecial: event.isSpecial,
                            lastModified: event.lastModified))
                        .toList()))
                .toList()))
        .then((_) async => await getCachedSchedules());
  }

  Future<void> permissionRequest(bool value) async {
    if (value) {
      await _notificationService.getPermission();
    }
    await _preferenceService.setNotificationAllowed(value);
  }

  Future<void> forceRefreshAll() async {
    final visibleBookmarks = _preferenceService.visibleBookmarkIds;

    for (var bookmark in visibleBookmarks) {
      final oldScheduleModel = await _databaseService.getOneSchedule(bookmark.scheduleId);
      final ScheduleOrProgrammeResponse apiResponse =
          await _cacheAndInteractionService.updateSchedule(bookmark.scheduleId);

      switch (apiResponse.status) {
        case ScheduleOrProgrammeStatus.FETCHED:
          final newScheduleModel = apiResponse.data as ScheduleModel;

          /// Update database with new information, except for the
          /// course colors in [.days]. So when we do getCachedSchedules()
          /// afterwards, it will have the same colors as before refreshing
          await _databaseService.update(ScheduleModel(
              cachedAt: newScheduleModel.cachedAt,
              id: newScheduleModel.id,
              days: _buildListOfDays(oldScheduleModel!, newScheduleModel)));
          break;
        default:
          break;
      }
    }
    await getCachedSchedules();
  }

  void cancelAllNotifications() => _notificationService.cancelAllNotifications();

  List<Day> _buildListOfDays(ScheduleModel oldScheduleModel, ScheduleModel newScheduleModel) {
    /// Create map of course id's and colors associated with course,
    /// due to the course being previously saved in the database we need
    /// to retrieve the colors and assign them to the incoming one
    Map<String, int> coursesAndColors = {};
    oldScheduleModel.days.map((day) => day.events).expand((listOfEvents) => listOfEvents).forEach((event) => {
          if (coursesAndColors[event.course.id] == null) {coursesAndColors[event.course.id] = event.course.courseColor!}
        });
    return newScheduleModel.days
        .map((day) => Day(
            name: day.name,
            date: day.date,
            isoString: day.isoString,
            weekNumber: day.weekNumber,
            events: day.events
                .map((event) => Event(
                    id: event.id,
                    title: event.title,
                    course: () {
                      /// Checks if incoming schedule course colors
                      /// are null, if they are then assign new random
                      /// colors.
                      if (event.course.courseColor == null) {
                        if (!coursesAndColors.containsKey(event.course.id)) {
                          coursesAndColors[event.course.id] = ColorPicker().getRandomHexColor();

                          /// If new course was added to incoming schedule it
                          ///  has to be accounted for dynamically
                          return Course(
                              id: event.course.id,
                              swedishName: event.course.swedishName,
                              englishName: event.course.englishName,
                              courseColor: coursesAndColors[event.course.id]);
                        }

                        return Course(
                            id: event.course.id,
                            swedishName: event.course.swedishName,
                            englishName: event.course.englishName,
                            courseColor: coursesAndColors[event.course.id]);
                      }
                      return event.course;
                    }(),
                    from: event.from,
                    to: event.to,
                    locations: event.locations,
                    teachers: event.teachers,
                    isSpecial: event.isSpecial,
                    lastModified: event.lastModified))
                .toList()))
        .toList();
  }
}
