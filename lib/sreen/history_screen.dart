import 'package:flutter/material.dart';

class LibraryTab extends StatelessWidget {
  final bool isLoggedIn;
  final List<Map<String, String>> history;
  final VoidCallback? onLoginTap;

  const LibraryTab({
    Key? key,
    required this.isLoggedIn,
    required this.history,
    this.onLoginTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 189, 22),
      ),
      child: isLoggedIn ? _buildHistory(context) : _buildGuestUI(context),
    );
  }

  /// Khi chưa đăng nhập
  Widget _buildGuestUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Đăng nhập để xem lịch sử quay và câu chuyện của bạn 🎯',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onLoginTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Đăng nhập ngay',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Khi đã đăng nhập
  Widget _buildHistory(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa có lần quay nào cả 🎰\nHãy thử vận may ngay hôm nay!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, i) {
          final item = history[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.amber[100],
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.deepOrange, size: 26),
              ),
              title: Text(
                item['title'] ?? 'Câu chuyện chưa rõ',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  item['content'] ?? '',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  maxLines: 3, // hiển thị tối đa 3 dòng
                  overflow: TextOverflow.ellipsis, // tự thêm "..." nếu dài
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showStoryDetail(context, item),
            ),
          );
        },
      ),
    );
  }

  /// Hiển thị chi tiết story đầy đủ
  void _showStoryDetail(BuildContext context, Map<String, String> story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Icon(Icons.auto_stories_rounded,
                    size: 40, color: Colors.amber),
                const SizedBox(height: 12),
                Text(
                  story['title'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 16),
                Text(
                  story['content'] ?? '',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text('Đóng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
