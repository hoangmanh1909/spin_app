import 'dart:math';

import 'package:flutter/material.dart';

class LuckyWheelScreen extends StatefulWidget {
  @override
  _LuckyWheelScreenState createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;
  double _currentRotation = 0;
  bool _isSpinning = false;
  int _selectedIndex = -1;

  final List<WheelItem> items = [
    WheelItem('Cuel a yuu', '🐕', Colors.yellow),
    WheelItem('Sube money', '💰', Colors.yellow.shade300),
    WheelItem('Love', '❤️', Colors.pink.shade300),
    WheelItem('Strong', '💪', Colors.orange.shade300),
    WheelItem('Gift', '🎁', Colors.green),
    WheelItem('Mystery', '❓', Colors.purple),
    WheelItem('Camera', '📷', Colors.blue.shade300),
    WheelItem('Shiba', '🐶', Colors.lightBlue.shade200),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = -1;
    });

    // Random số vòng quay (3-5 vòng) + góc dừng ngẫu nhiên
    final random = Random();
    final extraRotations = 3 + random.nextInt(3);
    final selectedIndex = random.nextInt(items.length);
    final anglePerItem = 360 / items.length;
    final targetAngle = (extraRotations * 360) +
        (selectedIndex * anglePerItem) +
        (anglePerItem / 2);

    _animation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentRotation = _animation!.value % 360;
        _isSpinning = false;
        _selectedIndex = selectedIndex;
      });

      // Hiển thị kết quả
      _showResult(items[selectedIndex]);
    });
  }

  void _showResult(WheelItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Chúc mừng!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.emoji,
              style: TextStyle(fontSize: 60),
            ),
            SizedBox(height: 16),
            Text(
              item.label,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 189, 22),
      body: Container(
        margin: EdgeInsets.only(top: 50),
        alignment: AlignmentDirectional.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'VÒNG QUAY CỦA BẠN',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 28),
                )),
            // Vòng quay
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation ?? _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          ((_animation?.value ?? _currentRotation) * pi / 180),
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: Size(320, 320),
                    painter: WheelPainter(items: items),
                  ),
                ),
                // Tâm vòng quay
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Mũi tên chỉ (ở trên)
                Positioned(
                  top: -10,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Nút quay
            ElevatedButton(
              onPressed: _isSpinning ? null : _spinWheel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
              ),
              child: Text(
                _isSpinning ? 'ĐANG QUAY...' : 'QUAY NGAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelItem {
  final String label;
  final String emoji;
  final Color color;

  WheelItem(this.label, this.emoji, this.color);
}

class WheelPainter extends CustomPainter {
  final List<WheelItem> items;

  WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final anglePerItem = 360 / items.length;

    // Vẽ viền ngoài
    final borderPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, borderPaint);

    for (int i = 0; i < items.length; i++) {
      final startAngle = (i * anglePerItem - 90) * pi / 180;
      final sweepAngle = anglePerItem * pi / 180;

      // Vẽ từng phần
      final paint = Paint()
        ..color = items[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Vẽ viền phân cách
      final dividerPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final dividerEnd = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      canvas.drawLine(center, dividerEnd, dividerPaint);

      // Vẽ text và emoji
      final middleAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.65;
      final textCenter = Offset(
        center.dx + textRadius * cos(middleAngle),
        center.dy + textRadius * sin(middleAngle),
      );

      canvas.save();
      canvas.translate(textCenter.dx, textCenter.dy);
      canvas.rotate(middleAngle + pi / 2);

      final emojiPainter = TextPainter(
        text: TextSpan(
          text: items[i].emoji,
          style: TextStyle(fontSize: 40), // Tăng size lên
        ),
        textDirection: TextDirection.ltr,
      );
      emojiPainter.layout();
      emojiPainter.paint(
        canvas,
        Offset(-emojiPainter.width / 2, -emojiPainter.height / 2), // Căn giữa
      );

      // // Vẽ emoji
      // final emojiPainter = TextPainter(
      //   text: TextSpan(
      //     text: items[i].emoji,
      //     style: TextStyle(fontSize: 32),
      //   ),
      //   textDirection: TextDirection.ltr,
      // );
      // emojiPainter.layout();
      // emojiPainter.paint(
      //   canvas,
      //   Offset(-emojiPainter.width / 2, -emojiPainter.height - 5),
      // );

      // Vẽ label
      // final textPainter = TextPainter(
      //   text: TextSpan(
      //     text: items[i].label,
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 12,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   textAlign: TextAlign.center,
      //   textDirection: TextDirection.ltr,
      // );
      // textPainter.layout();
      // textPainter.paint(
      //   canvas,
      //   Offset(-textPainter.width / 2, 5),
      // );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
