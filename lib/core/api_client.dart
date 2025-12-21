import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin_app/models/add_comment_request.dart';
import 'package:spin_app/models/add_history_request.dart';
import 'package:spin_app/models/add_user_request.dart';
import 'package:spin_app/models/change_password_request.dart';
import 'package:spin_app/models/login_request.dart';
import 'package:spin_app/models/response_object.dart';

class ApiClient {
  final Dio _dio = Dio();
  final String urlGateway = "https://api-spin.sanbox.io.vn/";
  // final String urlGateway = "http://localhost:5002/";

  Future<ResponseObject> getSpinConfig() async {
    try {
      Response response =
          await _dio.get("${urlGateway}api/Process/GetSpinConfig");

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> addUser(AddUserRequest req) async {
    try {
      Response response = await _dio.post("${urlGateway}api/Process/AddUser",
          data: req,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> login(LoginRequest req) async {
    try {
      Response response = await _dio.post("${urlGateway}api/Process/Login",
          data: req,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> addHistory(AddHistoryRequest req) async {
    try {
      Response response = await _dio.post("${urlGateway}api/Process/AddHistory",
          data: req,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> addFeed(AddHistoryRequest req) async {
    try {
      Response response = await _dio.post("${urlGateway}api/Feed/AddFeed",
          data: req,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException catch (e) {
      // ❌ Không có response → lỗi mạng
      if (e.response == null) {
        return ResponseObject(
          code: "98",
          message: "Không thể kết nối đến máy chủ",
        );
      }

      // ✅ Có response từ server
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      // 🔐 Token hết hạn
      if (statusCode == 401) {
        return ResponseObject(
          code: "401",
          message: "Phiên đăng nhập đã hết hạn",
        );
      }

      // ❌ Lỗi validate / nghiệp vụ backend
      if (statusCode == 400) {
        return ResponseObject.fromJson(data);
      }

      // 💥 Lỗi server
      if (statusCode == 500) {
        return ResponseObject(
          code: "500",
          message: "Lỗi hệ thống, vui lòng thử lại sau",
        );
      }

      // ❓ Trường hợp còn lại
      return ResponseObject(
        code: statusCode?.toString() ?? "99",
        message: data?["message"] ?? "Có lỗi xảy ra",
      );
    }
  }

  Future<ResponseObject> getHistoryByUser(int userId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/GetHistoryByUser?userId=$userId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> checkin(int userId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/Checkin?userId=$userId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> getCheckinStreak(int userId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/GetCheckinStreak?userId=$userId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> changeNumberOfTurn(
      int userId, int numberOfTurn) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/ChangeNumberOfTurn?userId=$userId&numberOfTurn=$numberOfTurn",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> removeUser(int userId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/RemoveUser?userId=$userId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> changePassword(ChangePasswordRequest req) async {
    try {
      Response response =
          await _dio.post("${urlGateway}api/Process/ChangePassword",
              data: req,
              options: Options(headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
              }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> getFeeds(
      int userId, int likeReadonly, int page, int limit) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/GetFeeds?userId=$userId&likeReadonly=$likeReadonly&page=$page&limit=$limit",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> likeOrDislike(int userId, int feedId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Process/LikeOrDislike?userId=$userId&feedId=$feedId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> getCommentByFeed(int feedId) async {
    try {
      Response response = await _dio.get(
        "${urlGateway}api/Feed/GetCommentsByFeedId?feedId=$feedId",
        options: Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
        }),
      );

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<ResponseObject> addComment(AddNewCommentRequest req) async {
    try {
      Response response = await _dio.post("${urlGateway}api/Feed/AddNewComment",
          data: req.toJson(),
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${await getToken()}",
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    return accessToken ?? "";
  }
}
