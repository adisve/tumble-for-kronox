import 'package:tumble/core/models/api_models/kronox_user_model.dart';
import 'package:tumble/core/models/api_models/schedule_model.dart';

abstract class IDatabaseScheduleService {
  Future addSchedule(ScheduleModel scheduleModel);

  Future updateSchedule(ScheduleModel scheduleModel);

  Future removeSchedule(String id);

  Future<List<ScheduleModel>> getAllSchedules();

  Future<List<String>> getAllScheduleIds();

  Future<ScheduleModel?> getOneSchedule(String id);

  Future removeAllSchedules();
  Future setUserSession(KronoxUserModel kronoxUser);

  Future removeUserSession();

  Future<KronoxUserModel?> getUserSession();
}
