import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:spin_app/core/api_client.dart';
import 'package:spin_app/models/add_comment_request.dart';
import 'package:spin_app/models/response_object.dart';

class FeedController extends ControllerMVC {
  factory FeedController() => _this ??= FeedController._();
  FeedController._();
  static FeedController? _this;
  final ApiClient _apiClient = ApiClient();

  Future<ResponseObject> getCommentsByFeed(int feedId) async {
    return await _apiClient.getCommentByFeed(feedId);
  }

  Future<ResponseObject> addComment(AddNewCommentRequest req) async {
    return await _apiClient.addComment(req);
  }
}
