import 'package:flutter/material.dart';
import 'package:spin_app/sreen/lucky_wheel_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final WheelItem item;
  const StoryDetailScreen({super.key, required this.item});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  String? title;
  String? content;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loading = false;
    title = widget.item.label; // hoặc "🌟 Vòng quay Cảm xúc buổi sáng"
    content = 'Hôm nay có gì đó bất ngờ đang chờ bạn... 🌤️';
    // _loadStory();
  }

  // Future<void> _loadStory() async {
  //   setState(() {
  //     title = story['title'];
  //     content = story['content'];
  //     loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title ?? '',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              content ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (title != null && content != null) {
                    // saveToAlbum(title!, content!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã lưu vào Thư viện 📖')),
                    );
                  }
                },
                icon: const Icon(Icons.bookmark_add_outlined,
                    color: Colors.black),
                label: const Text(
                  "Lưu vào Thư viện",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nút xem quảng cáo
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline),
                label: const Text(
                  "Xem quảng cáo nhận lượt quay",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
