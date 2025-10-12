// ignore_for_file: unnecessary_getters_setters, prefer_collection_literals

class ResponseObject {
  String? _code;
  String? _message;
  String? _data;
  String? _accessToken;

  ResponseObject(
      {String? code, String? message, String? data, String? accessToken}) {
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
    if (data != null) {
      _data = data;
    }
    if (accessToken != null) {
      _accessToken = accessToken;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  String? get message => _message;
  set message(String? message) => _message = message;
  String? get data => _data;
  set data(String? data) => _data = data;
  String? get accessToken => _accessToken;
  set accessToken(String? accessToken) => _accessToken = accessToken;

  ResponseObject.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _message = json['Message'];
    _data = json['Data'];
    _accessToken = json['AccessToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Code'] = _code;
    data['Message'] = _message;
    data['Data'] = _data;
    data['AccessToken'] = _accessToken;
    return data;
  }
}
