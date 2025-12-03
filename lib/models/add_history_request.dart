class AddHistoryRequest {
  int? userId;
  int? itemId;
  String? title;
  String? content;
  String? feedStatus;

  AddHistoryRequest(
      {this.userId, this.itemId, this.title, this.content, this.feedStatus});

  AddHistoryRequest.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    itemId = json['ItemId'];
    content = json['Content'];
    feedStatus = json['FeedStatus'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['ItemId'] = itemId;
    data['Content'] = content;
    data['FeedStatus'] = feedStatus;
    data['Title'] = title;
    return data;
  }
}
