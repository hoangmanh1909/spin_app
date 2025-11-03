import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedItem {
  final int id;
  final String title;
  final String content;
  int likes;
  bool isLiked;
  DateTime createdAt;

  FeedItem({
    required this.id,
    required this.title,
    required this.content,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
  });
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<FeedItem> feeds = List.generate(
    6,
    (i) => FeedItem(
      id: i,
      title: [
        "Thử Thách Vui",
        "Tin Nhắn Tình Yêu",
        "Biết Chưa Nè",
        "Vận May Hôm Nay"
      ][i % 4],
      content: [
        "Hãy gửi một lời động viên đến người thân của bạn ngay hôm nay 💌",
        "Dù có mưa rơi, cầu vồng sẽ lại xuất hiện 🌈",
        "Hoa hướng dương luôn hướng về mặt trời, bạn cũng vậy nhé 🌻",
        "Bạn đã thử làm điều gì mới hôm nay chưa? 🌟"
      ][i % 4],
      likes: i * 2 + 3,
      isLiked: i % 2 == 0,
      createdAt: DateTime.now().subtract(Duration(minutes: i * 12)),
    ),
  );

  Future<void> _refreshFeeds() async {
    await Future.delayed(const Duration(seconds: 1));
    // sau này thay bằng API load lại feed
  }

  void _toggleLike(FeedItem item) {
    setState(() {
      item.isLiked = !item.isLiked;
      item.likes += item.isLiked ? 1 : -1;
    });
  }

  void _openLikedStories() {
    // mở trang "Câu chuyện đã thích"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đi tới danh sách câu chuyện đã thích ❤️")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshFeeds,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              // ---- Header nhẹ nhàng thay cho AppBar ----
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ô tìm kiếm
                    Expanded(
                      child: SizedBox(
                        height: 46, // ✅ cùng chiều cao với nút "Đã thích"
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            hintText: 'Tìm kiếm...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Nút "Đã thích"
                    SizedBox(
                      height: 46, // ✅ bằng chiều cao TextField
                      child: GestureDetector(
                        onTap: _openLikedStories,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.favorite, color: Colors.red, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "Đã thích",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Danh sách feed ----
              ...feeds.map((item) => _buildFeedCard(item)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedCard(FeedItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Tiêu đề ---
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // --- Nội dung ---
            Text(
              item.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 10),

            // --- Like + thời gian ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(item),
                      child: Icon(
                        item.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: item.isLiked ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${item.likes}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm • dd/MM').format(item.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
