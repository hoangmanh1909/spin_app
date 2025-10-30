import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin_app/models/add_history_request.dart';
import 'package:spin_app/models/add_user_request.dart';
import 'package:spin_app/models/login_request.dart';
import 'package:spin_app/models/response_object.dart';

class ApiClient {
  final Dio _dio = Dio();
  final String urlGateway = "http://202.134.18.27:8005/";
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

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    return accessToken ?? "";
  }
}
