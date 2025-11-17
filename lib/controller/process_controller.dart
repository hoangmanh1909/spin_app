import 'package:spin_app/core/api_client.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:spin_app/models/add_history_request.dart';
import 'package:spin_app/models/add_user_request.dart';
import 'package:spin_app/models/change_password_request.dart';
import 'package:spin_app/models/login_request.dart';

class ProcessController extends ControllerMVC {
  factory ProcessController() => _this ??= ProcessController._();
  ProcessController._();
  static ProcessController? _this;
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> getSpinConfig() async {
    return await _apiClient.getSpinConfig();
  }

  Future<dynamic> getHistoryByUser(id) async {
    return await _apiClient.getHistoryByUser(id);
  }

  Future<dynamic> addUser(AddUserRequest req) async {
    return await _apiClient.addUser(req);
  }

  Future<dynamic> login(LoginRequest req) async {
    return await _apiClient.login(req);
  }

  Future<dynamic> addHistory(AddHistoryRequest req) async {
    return await _apiClient.addHistory(req);
  }

  Future<dynamic> checkin(userId) async {
    return await _apiClient.checkin(userId);
  }

  Future<dynamic> getCheckinStreak(userId) async {
    return await _apiClient.getCheckinStreak(userId);
  }

  Future<dynamic> changeNumberOfTurn(userId, numberOfTurn) async {
    return await _apiClient.changeNumberOfTurn(userId, numberOfTurn);
  }

  Future<dynamic> removeUser(userId) async {
    return await _apiClient.removeUser(userId);
  }

  Future<dynamic> changePassword(ChangePasswordRequest req) async {
    return await _apiClient.changePassword(req);
  }

  Future<dynamic> getFeeds(int userId, int page, int limit) async {
    return await _apiClient.getFeeds(userId, page, limit);
  }

  Future<dynamic> likeOrDislike(int userId, int feedId) async {
    return await _apiClient.likeOrDislike(userId, feedId);
  }
}
