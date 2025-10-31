class AddHistoryResponse {
  String? title;
  String? content;

  AddHistoryResponse({this.title, this.content});

  AddHistoryResponse.fromJson(Map<String, dynamic> json) {
    title = json['Title'];
    content = json['Content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Title'] = title;
    data['Content'] = content;
    return data;
  }
}
