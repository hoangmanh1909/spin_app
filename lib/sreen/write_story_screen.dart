import 'package:flutter/material.dart';

class WriteStoryScreen extends StatefulWidget {
  final Function({
    required String title,
    required String content,
    required bool shareToExplore,
  })? onSubmit;

  const WriteStoryScreen({super.key, this.onSubmit});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  bool shareToExplore = false;
  bool submitting = false;

  void _submit() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập đầy đủ nội dung")));
      return;
    }

    setState(() => submitting = true);

    await widget.onSubmit?.call(
      title: _title.text.trim(),
      content: _content.text.trim(),
      shareToExplore: shareToExplore,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 207, 64),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Khoảnh khắc của bạn",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // ---------- CARD CHIẾM TOÀN VÙNG CÒN LẠI ----------
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Tiêu đề
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(
                      hintText: "Tiêu đề...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Nội dung co giãn trong không gian còn lại
                  Expanded(
                    child: TextField(
                      controller: _content,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        hintText: "Kể câu chuyện của bạn...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- NÚT CHIA SẺ & LƯU ----------
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // -------------------- SHARE TOGGLE --------------------
  Widget _buildShareToggle() {
    final active = shareToExplore;

    const purple = Color(0xFF9C4CE3);
    const purpleLight = Color(0xFFD3B3F7);

    return GestureDetector(
      onTap: () => setState(() => shareToExplore = !shareToExplore),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              active ? purple.withOpacity(0.25) : purpleLight.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? purple : purpleLight,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_circle : Icons.circle_outlined,
              color: purple,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              "Chia sẻ lên Khám phá",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- BOTTOM BUTTONS --------------------
  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          _buildShareToggle(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Lưu khoảnh khắc",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
