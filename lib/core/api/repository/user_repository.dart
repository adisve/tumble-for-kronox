import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumble/core/api/apiservices/api_response.dart';
import 'package:tumble/core/api/interface/iuser_service.dart';
import 'package:tumble/core/api/repository/backend_repository.dart';
import 'package:tumble/core/shared/preference_types.dart';
import 'package:tumble/core/startup/get_it_instances.dart';

class UserRepository implements IUserService {
  final _backendRepository = locator<BackendRepository>();
  final _sharedPrefs = locator<SharedPreferences>();

  @override
  Future<ApiResponse> getUserEvents(String sessionToken) async {
    final school = _sharedPrefs.getString(PreferenceTypes.school)!;

    return await _backendRepository.getUserEvents(sessionToken, school);
  }

  @override
  Future<ApiResponse> postUserLogin(
      String username, String password, String school) async {
    return await _backendRepository.postUserLogin(username, password, school);
  }

  @override
  Future putRegisterUserEvent(String eventId, String sessionToken) async {
    final school = _sharedPrefs.getString(PreferenceTypes.school)!;

    return await _backendRepository.putRegisterUserEvent(
        eventId, sessionToken, school);
  }

  @override
  Future putUnregisterUserEvent(String eventId, String sessionToken) async {
    final school = _sharedPrefs.getString(PreferenceTypes.school)!;

    return await _backendRepository.putUnregisterUserEvent(
        eventId, sessionToken, school);
  }

  @override
  Future<ApiResponse> getRefreshSession(String refreshToken) async {
    String? school = _sharedPrefs.getString(PreferenceTypes.school);

    if (school != null) {
      return await _backendRepository.getRefreshSession(refreshToken, school);
    }
    return ApiResponse.error('No school');
  }
}
