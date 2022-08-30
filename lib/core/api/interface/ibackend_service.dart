import 'package:flutter/foundation.dart';

@immutable
abstract class IBackendService {
  /// [HttpGet]
  Future<dynamic> getRequestSchedule(String scheduleId, String defaultSchool);

  /// [HttpGet]
  Future<dynamic> getPrograms(String searchQuery, String defaultSchool);

  /// [HttpGet]
  Future<dynamic> getUserEvents(String sessionToken, String defaultSchool);

  /// [HttpGet]
  Future<dynamic> getRefreshSession(String refreshToken, String defaultSchool);

  /// [HttpPost]
  Future<dynamic> postUserLogin(
      String username, String password, String defaultSchool);

  /// [HttpPut]
  Future<dynamic> putRegisterUserEvent(
      String eventId, String sessionToken, String defaultSchool);

  /// [HttpPut]
  Future<dynamic> putUnregisterUserEvent(
      String eventId, String sessionToken, String defaultSchool);

  /// [HttpPut]
  Future putRegisterAllAvailableUserEvents(
      String sessionToken, String defaultSchool);

  /// [HttpPost]
  Future<dynamic> postSubmitIssue(String issueSubject, String issueBody);
}
