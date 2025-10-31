class ChangePasswordRequest {
  int? id;
  String? currentPassword;
  String? newPassword;

  ChangePasswordRequest({this.id, this.currentPassword, this.newPassword});

  ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    currentPassword = json['CurrentPassword'];
    newPassword = json['NewPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['CurrentPassword'] = currentPassword;
    data['NewPassword'] = newPassword;
    return data;
  }
}
