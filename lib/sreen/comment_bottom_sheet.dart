import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spin_app/controller/fee_controller.dart';
import 'package:spin_app/models/add_comment_request.dart';
import 'package:spin_app/models/add_history_request.dart';
import 'package:spin_app/models/feed_comment_response.dart';
import 'package:spin_app/models/response_object.dart';

class CommentBottomSheet extends StatefulWidget {
  final int feedId;
  final VoidCallback? onCommentAdded;
  final int userId;

  const CommentBottomSheet({
    super.key,
    required this.feedId,
    required this.userId,
    this.onCommentAdded,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  List<FeedCommentResponse> comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    ResponseObject res =
        await FeedController().getCommentsByFeed(widget.feedId);
    if (!mounted) return;
    if (res.code != "00") {
      // lỗi thì hiện thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? "Đã có lỗi xảy ra")),
      );
      setState(() => _loading = false);
      return;
    }
    comments = List<FeedCommentResponse>.from((jsonDecode(res.data!)
        .map((model) => FeedCommentResponse.fromJson(model))));
    setState(() => _loading = false);
  }

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty) return;

    // gọi API ADD_COMMENT
    AddNewCommentRequest req = AddNewCommentRequest(
        feedId: widget.feedId,
        content: _controller.text.trim(),
        userId: widget.userId);
    _controller.clear();

    ResponseObject res = await FeedController().addComment(req);
    if (!mounted) return;
    if (res.code != "00") {
      // lỗi thì hiện thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? "Đã có lỗi xảy ra")),
      );
      return;
    }
    widget.onCommentAdded?.call(); // 🔥 báo cho feed tăng count

    Navigator.pop(context); // v1: gửi xong đóng luôn cho gọn
  }

  Widget _buildCommentInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 6,
          top: 6,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // 😊 Emoji
                    GestureDetector(
                      onTap: _openEmojiPicker,
                      child: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // 🚀 Send
            GestureDetector(
              onTap: _sendComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEmojiPicker() {
    setState(() {
      _controller.text += "😊";
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55, // 🔥 MỞ NỬA MÀN
      minChildSize: 0.45, // 🔥 KÉO XUỐNG ĐỂ ĐÓNG
      maxChildSize: 1.0, // 🔥 KÉO LÊN FULL
      builder: (context, scrollController) {
        return Container(
          height: MediaQuery.of(context).size.height, // 🔥 đảm bảo full
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // handle
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: comments.isEmpty
                    ? _buildEmptyComment()
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: comments.length,
                        itemBuilder: (_, i) => _buildCommentItem(comments[i]),
                      ),
              ),

              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyComment() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có bình luận nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hãy là người đầu tiên chia sẻ suy nghĩ của bạn nhé 😊',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(FeedCommentResponse c) {
    final bool isMine = c.userId == widget.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 AVATAR CHỮ
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _colorFromName(c.userName!),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              c.userName!.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 💬 BUBBLE
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  Text(
                    c.userName!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isMine ? Colors.orange.shade800 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // CONTENT
                  Text(
                    c.content!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromName(String name) {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.redAccent,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
