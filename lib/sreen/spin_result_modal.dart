import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SpinResultModal {
  static Future<void> show(
    BuildContext context, {
    required String slotName,
    String? story, // story có thể null nếu chưa login
    required bool isLoggedIn,
    VoidCallback? onLoginTap,
    VoidCallback? onViewDetail,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SpinResult',
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = Curves.easeOut.transform(anim1.value);
        return Transform.scale(
          scale: 0.9 + curved * 0.1,
          child: Opacity(
            opacity: anim1.value,
            child: _SpinResultDialog(
              slotName: slotName,
              story: story,
              isLoggedIn: isLoggedIn,
              onLoginTap: onLoginTap,
              onViewDetail: onViewDetail,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

class _SpinResultDialog extends StatefulWidget {
  final String slotName;
  final String? story;
  final bool isLoggedIn;
  final VoidCallback? onLoginTap;
  final VoidCallback? onViewDetail;

  const _SpinResultDialog({
    Key? key,
    required this.slotName,
    this.story,
    required this.isLoggedIn,
    this.onLoginTap,
    this.onViewDetail,
  }) : super(key: key);

  @override
  State<_SpinResultDialog> createState() => _SpinResultDialogState();
}

class _SpinResultDialogState extends State<_SpinResultDialog> {
  late ConfettiController _confettiController;
  bool _navigating = false;
  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStory =
        widget.story != null && widget.story!.trim().isNotEmpty;

    return Material(
      color: Colors.black45,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                child: SizedBox(
                  width: 200,
                  height: 120,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 25,
                    gravity: 0.15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('🎉', style: TextStyle(fontSize: 26)),
                        SizedBox(width: 8),
                        Text(
                          'CHÚC MỪNG!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('🥳', style: TextStyle(fontSize: 26)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bạn vừa quay trúng ô:',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.slotName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // story hoặc nhắc đăng nhập
                    if (!widget.isLoggedIn) ...[
                      const Icon(Icons.lock_outline,
                          color: Colors.grey, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Hãy đăng nhập để xem câu chuyện của bạn!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _navigating
                            ? null
                            : () async {
                                // đóng modal trước
                                Navigator.of(context).pop();

                                // tránh double call
                                setState(() => _navigating = true);

                                // gọi callback (nó sẽ push AuthScreen)
                                try {
                                  widget.onLoginTap?.call();
                                } finally {
                                  // chỉ để an toàn; modal đã đóng nên state này không quan trọng nữa
                                  // nhưng giữ để tránh trạng thái treo
                                  setState(() => _navigating = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 244, 219, 27),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Đăng nhập ngay',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Quay tiếp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else if (hasStory) ...[
                      Text(
                        widget.story!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ] else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text(
                        'Đang tạo câu chuyện của bạn...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Nút điều khiển chung
                    if (widget.isLoggedIn) ...[
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 244, 219, 27),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Quay tiếp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onViewDetail?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
