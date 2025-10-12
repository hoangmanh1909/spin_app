class AddHistoryRequest {
  int? userId;
  int? itemId;

  AddHistoryRequest({this.userId, this.itemId});

  AddHistoryRequest.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    itemId = json['ItemId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['ItemId'] = itemId;
    return data;
  }
}
