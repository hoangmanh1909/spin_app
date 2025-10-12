import 'dart:io';

import 'package:dio/dio.dart';
import 'package:spin_app/models/add_history_request.dart';
import 'package:spin_app/models/add_user_request.dart';
import 'package:spin_app/models/login_request.dart';
import 'package:spin_app/models/response_object.dart';

class ApiClient {
  final Dio _dio = Dio();
  final String urlGateway = "http://202.134.18.27:8005/";

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

  Future<ResponseObject> getHistoryByUser(int userId) async {
    try {
      Response response = await _dio
          .get("${urlGateway}api/Process/GetHistoryByUser?userId=$userId");

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
          }));

      return ResponseObject.fromJson(response.data);
    } on DioException {
      ResponseObject responseObject =
          ResponseObject(code: "98", message: "Không thể kết nối đến máy chủ");
      return responseObject;
    }
  }
}
