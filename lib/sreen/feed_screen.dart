import 'package:flutter/material.dart';

class FeedItem {
  final int id;
  final String username;
  final String content;
  bool isLiked;
  int likes;
  final DateTime createdAt;
  final String? avatarUrl;

  FeedItem({
    required this.id,
    required this.username,
    required this.content,
    this.isLiked = false,
    this.likes = 0,
    required this.createdAt,
    this.avatarUrl,
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<FeedItem> feeds = [];

  @override
  void initState() {
    super.initState();
    // dữ liệu mẫu (giống như API trả về)
    feeds = List.generate(8, (i) {
      return FeedItem(
        id: i,
        username: "Người chơi ${i + 1}",
        content: "“${[
          "Hôm nay thật tuyệt!",
          "Tôi quay trúng phần thưởng lớn 🎁",
          "Một câu chuyện vui vẻ cho ngày mới ☀️",
          "Tôi đã cười rất nhiều vì trò chơi này 😂"
        ][i % 4]}”",
        isLiked: i % 3 == 0,
        likes: 5 + i,
        createdAt: DateTime.now().subtract(Duration(minutes: i * 7)),
      );
    });
  }

  void toggleLike(FeedItem item) {
    setState(() {
      item.isLiked = !item.isLiked;
      item.likes += item.isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("📖 Bảng Câu Chuyện"),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: feeds.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = feeds[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + tên + thời gian
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: item.avatarUrl != null
                            ? NetworkImage(item.avatarUrl!)
                            : const AssetImage("assets/avatar_placeholder.png")
                                as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              "${DateTime.now().difference(item.createdAt).inMinutes} phút trước",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onPressed: () {},
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nội dung câu chuyện
                  Text(
                    item.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Like / comment / share
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          item.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: item.isLiked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => toggleLike(item),
                      ),
                      Text(
                        '${item.likes}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: Colors.grey),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
