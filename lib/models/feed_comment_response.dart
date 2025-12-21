class FeedCommentResponse {
  int? commentId;
  int? feedId;
  int? userId;
  String? userName;
  String? content;
  String? createdAt;

  FeedCommentResponse(
      {this.commentId,
      this.feedId,
      this.userId,
      this.userName,
      this.content,
      this.createdAt});

  FeedCommentResponse.fromJson(Map<String, dynamic> json) {
    commentId = json['CommentId'];
    feedId = json['FeedId'];
    userId = json['UserId'];
    userName = json['UserName'];
    content = json['Content'];
    createdAt = json['CreatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CommentId'] = commentId;
    data['FeedId'] = feedId;
    data['UserId'] = userId;
    data['UserName'] = userName;
    data['Content'] = content;
    data['CreatedAt'] = createdAt;
    return data;
  }
}
