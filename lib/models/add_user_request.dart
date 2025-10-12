class AddUserRequest {
  String? userName;
  String? fullName;
  String? avatar;
  String? password;

  AddUserRequest({this.userName, this.fullName, this.avatar, this.password});

  AddUserRequest.fromJson(Map<String, dynamic> json) {
    userName = json['UserName'];
    fullName = json['FullName'];
    avatar = json['Avatar'];
    password = json['Password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserName'] = userName;
    data['FullName'] = fullName;
    data['Avatar'] = avatar;
    data['Password'] = password;
    return data;
  }
}
