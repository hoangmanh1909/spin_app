class FeedResponse {
  int? id;
  int? userId;
  int? itemId;
  String? content;
  String? isCustom;
  int? likes;
  int? commentCount;
  String? createdAt;
  String? title;

  FeedResponse(
      {this.id,
      this.userId,
      this.itemId,
      this.content,
      this.isCustom,
      this.likes,
      this.createdAt,
      this.title});

  FeedResponse.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    userId = json['UserId'];
    itemId = json['ItemId'];
    content = json['Content'];
    isCustom = json['IsCustom'];
    likes = json['Likes'];
    createdAt = json['CreatedAt'];
    title = json['Title'];
    commentCount = json['CommentCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['UserId'] = userId;
    data['ItemId'] = itemId;
    data['Content'] = content;
    data['IsCustom'] = isCustom;
    data['Likes'] = likes;
    data['CreatedAt'] = createdAt;
    data['Title'] = title;
    data['CommentCount'] = commentCount;
    return data;
  }
}
