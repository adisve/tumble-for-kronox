import 'dart:developer';

import 'package:flutter/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumble/core/api/backend/response_types/schedule_or_programme_response.dart';
import 'package:tumble/core/api/backend/data/constants.dart';
import 'package:tumble/core/api/backend/repository/backend_repository.dart';
import 'package:tumble/core/api/preferences/repository/preference_repository.dart';
import 'package:tumble/core/api/database/repository/database_repository.dart';
import 'package:tumble/core/models/backend_models/bookmarked_schedule_model.dart';
import 'package:tumble/core/models/backend_models/schedule_model.dart';
import 'package:tumble/core/shared/preference_types.dart';
import 'package:tumble/core/api/dependency_injection/get_it.dart';
import 'package:tumble/core/theme/color_picker.dart';
import 'package:tumble/core/ui/schedule/utils/day_list_builder.dart';

import '../../notifications/repository/notification_repository.dart';

class BackgroundTask {
  ///
  /// Background update attempted on boot sequence.
  /// Function updates only the visible schedules and will only update schedules
  /// if they have not been updated in the last 30 minutes.
  static Future<void> callbackDispatcher() async {
    final backendService = getIt<BackendRepository>();
    final preferenceService = getIt<PreferenceRepository>();
    final databaseService = getIt<DatabaseRepository>();
    final notificationService = getIt<NotificationRepository>();

    final bookmarkedSchedulesToggledToBeVisible = preferenceService.visibleBookmarkIds;

    final defaultUserSchool = preferenceService.defaultSchool;

    if (bookmarkedSchedulesToggledToBeVisible.isEmpty || defaultUserSchool == null) {
      return;
    }

    log(name: 'background_task', 'Executing background updater ..');
    List<ScheduleModel?> cachedScheduleModels = await Future.wait(bookmarkedSchedulesToggledToBeVisible
        .map((bookmarkedScheduleModel) async =>
            (await databaseService.getOneSchedule(bookmarkedScheduleModel.scheduleId)))
        .toList());

    for (ScheduleModel? cachedScheduleModel in cachedScheduleModels) {
      if (cachedScheduleModel != null) {
        if (cachedScheduleModel.cachedAt.isAfter(DateTime.now().subtract(Constants.updateOffset))) {
          return;
        }

        ScheduleOrProgrammeResponse apiResponseOfNewScheduleModel =
            await backendService.getSchedule(cachedScheduleModel.id, defaultUserSchool);

        switch (apiResponseOfNewScheduleModel.status) {
          case ScheduleOrProgrammeStatus.FETCHED:
            ScheduleModel newScheduleModel = apiResponseOfNewScheduleModel.data!;

            if (newScheduleModel.days != cachedScheduleModel.days) {
              databaseService.update(ScheduleModel(
                  cachedAt: newScheduleModel.cachedAt,
                  id: newScheduleModel.id,
                  days: await DayListBuilder.buildListOfDays(newScheduleModel, databaseService)));

              notificationService.updateDispatcher(newScheduleModel, cachedScheduleModel);
            }
            break;

          /// Connection is not available or backend is down. No point
          /// in attempting to update any other schedules if this goes wrong.
          case ScheduleOrProgrammeStatus.ERROR:
            log(name: 'background_task', 'Failed to update schedules forcefully. Connection not available. Exiting ..');
            return;
          default:
            break;
        }
      }
    }
  }
}
