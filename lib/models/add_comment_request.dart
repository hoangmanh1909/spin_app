class AddNewCommentRequest {
  int? feedId;
  int? userId;
  String? userName;
  String? content;
  String? status;
  String? createdIp;
  String? deviceId;

  AddNewCommentRequest(
      {this.feedId,
      this.userId,
      this.userName,
      this.content,
      this.status,
      this.createdIp,
      this.deviceId});

  AddNewCommentRequest.fromJson(Map<String, dynamic> json) {
    feedId = json['FeedId'];
    userId = json['UserId'];
    userName = json['UserName'];
    content = json['Content'];
    status = json['Status'];
    createdIp = json['CreatedIp'];
    deviceId = json['DeviceId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FeedId'] = feedId;
    data['UserId'] = userId;
    data['UserName'] = userName;
    data['Content'] = content;
    data['Status'] = status;
    data['CreatedIp'] = createdIp;
    data['DeviceId'] = deviceId;
    return data;
  }
}
