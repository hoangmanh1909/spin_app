class GetHistoryResponse {
  String? type;
  String? content;
  String? createdDate;

  GetHistoryResponse({this.type, this.content, this.createdDate});

  GetHistoryResponse.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    content = json['Content'];
    createdDate = json['CreatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Type'] = type;
    data['Content'] = content;
    data['CreatedDate'] = createdDate;
    return data;
  }
}
