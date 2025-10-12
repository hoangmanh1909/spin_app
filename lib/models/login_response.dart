class LoginResponse {
  int? id;
  String? userName;
  String? fullName;
  String? avatar;
  String? createdDate;

  LoginResponse(
      {this.id, this.userName, this.fullName, this.avatar, this.createdDate});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userName = json['UserName'];
    fullName = json['FullName'];
    avatar = json['Avatar'];
    createdDate = json['CreatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['UserName'] = userName;
    data['FullName'] = fullName;
    data['Avatar'] = avatar;
    data['CreatedDate'] = createdDate;
    return data;
  }
}
