import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/response_object.dart';
import 'package:spin_app/models/spin_config_response.dart';
import 'package:spin_app/sreen/auth_sreen.dart';
import 'package:spin_app/sreen/detail_screen.dart';
import 'package:spin_app/sreen/spin_result_modal.dart';
import 'dart:ui' as ui;
import 'package:spin_app/utils/image_cache.dart';

class LuckyWheelScreen extends StatefulWidget {
  @override
  _LuckyWheelScreenState createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _dotController;
  String _dots = '';

  final ProcessController _con = ProcessController();

  Animation<double>? _animation;

  double _currentRotation = 0;
  bool _isSpinning = false;
  int _selectedIndex = -1;
  String? storyFromAPI;
  bool isUserLoggedIn = false;
  Map<String, ui.Image?> _loadedImages = {}; // ✅ Cache ảnh
  bool _isLoadingImages = true;

  List<WheelItem> items = [];

  //   WheelItem('Cuel a yuu', '🐕', Colors.yellow),
  //   WheelItem('Sube money', '💰', Colors.yellow.shade300),
  //   WheelItem('Love', '❤️', Colors.pink.shade300),
  //   WheelItem('Strong', '💪', Colors.orange.shade300),
  //   WheelItem('Gift', '🎁', Colors.green),
  //   WheelItem('Mystery', '❓', Colors.purple),
  //   WheelItem('Camera', '📷', Colors.blue.shade300),
  //   WheelItem('Shiba', '🐶', Colors.lightBlue.shade200),
  // ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Animation cho hiệu ứng "..."
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )
      ..addListener(() {
        final count = (3 * _dotController.value).floor() + 1;
        setState(() => _dots = '.' * count);
      })
      ..repeat();

    Future.microtask(() => _loadSpinConfig());
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  Color _getColorByType(String type) {
    switch (type) {
      case "AnimalMeme":
        return Colors.yellow;
      case "FunFact":
        return Colors.yellow.shade300;
      case "LoveNote":
        return Colors.pink.shade300;
      case "Fortune":
        return Colors.orange.shade300;
      case "Reward":
        return Colors.green;
      case "Mystery":
        return Colors.purple;
      case "Challenge":
        return Colors.blue.shade300;
      case "MemeText":
        return Colors.lightBlue.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  void _loadSpinConfig() async {
    try {
      final box = await Hive.openBox('spin_cache');
      final cachedData = box.get('spin_items');

      // 🧠 B1: nếu có cache → load trước (để giao diện không trống)
      if (cachedData != null) {
        final cachedList = (jsonDecode(cachedData) as List).map((e) {
          try {
            final content = e['ItemContent']?.toString() ?? '[null-content]';
            final image = e['Image']?.toString() ?? '[null-image]';
            final type = e['ItemType']?.toString() ?? '[null-type]';

            return WheelItem(content, image, _getColorByType(type), e['Id']);
          } catch (err) {
            rethrow;
          }
        }).toList();

        if (mounted) {
          setState(() => items = cachedList);
          await _loadImages();
          setState(() {
            _isLoadingImages = false;
          });
        }
      }
      ResponseObject res = await _con.getSpinConfig();

      if (res.code == "00") {
        if (mounted) {
          List<SpinConfigResponse> spin = List<SpinConfigResponse>.from(
              (jsonDecode(res.data!)
                  .map((model) => SpinConfigResponse.fromJson(model))));

          List<WheelItem> items1 = [];
          for (int i = 0; i < spin.length; i++) {
            var _spin = spin[i];

            WheelItem item = WheelItem(_spin.itemContent!, _spin.image!,
                _getColorByType(_spin.itemType!), _spin.id!);
            items1.add(item);
          }
          if (mounted) {
            setState(() => items = items1);
          }
          await box.put('spin_items', res.data);
          await _loadImages();
          setState(() {
            _isLoadingImages = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ ${res.message}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Lỗi mạng: $e')),
        );
      }
    }
  }

  Future<void> _loadImages() async {
    final Map<String, ui.Image?> newImages = {};

    for (var item in items) {
      if (item.emoji.startsWith('http')) {
        final image = await ImageSpinCache.loadImage(item.emoji);
        newImages[item.emoji] = image;
      }
    }

    if (mounted) {
      setState(() {
        _loadedImages = newImages;
        _isLoadingImages = false; // ✅ Khi load xong
      });
      _fadeController.forward(); // ✅ Fade-in vòng quay
    }
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = -1;
    });

    // Random số vòng quay (3-5 vòng) + góc dừng ngẫu nhiên
    final random = Random();
    final extraRotations = 5 + random.nextInt(3);
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
    SpinResultModal.show(
      context,
      slotName: 'Ô may mắn số 7',
      story: storyFromAPI,
      isLoggedIn: isUserLoggedIn,
      onLoginTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );

        if (result == true) {
          setState(() => isUserLoggedIn = true);
          // ✅ Mở lại modal kết quả sau khi login
          Future.delayed(const Duration(milliseconds: 300), () {
            SpinResultModal.show(
              context,
              slotName: 'Ô may mắn số 7',
              story: storyFromAPI,
              isLoggedIn: true,
              onViewDetail: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StoryDetailScreen(item: item)),
              ),
            );
          });
        }
      },
      onViewDetail: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StoryDetailScreen(item: item)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 189, 22),
      body: SingleChildScrollView(
          child: Container(
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: !_isLoadingImages
                      ? SizedBox(
                          width: 320,
                          height: 320, // ✅ đảm bảo kích thước cố định
                          child: FadeTransition(
                            key: const ValueKey("wheel"),
                            opacity: _fadeAnimation,
                            child: Transform.rotate(
                              angle: ((_animation?.value ?? _currentRotation) *
                                  pi /
                                  180),
                              alignment: Alignment.center,
                              child: CustomPaint(
                                size: const Size(320, 320),
                                painter: WheelPainter(
                                    items: items, images: _loadedImages),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 320,
                          height: 320, // ✅ giữ chiều cao bằng nhau
                          child: Column(
                            key: const ValueKey("loading"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _controller
                                      ..repeat(
                                          period: const Duration(seconds: 3)),
                                    curve: Curves.linear,
                                  ),
                                ),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: SweepGradient(
                                      colors: [
                                        Colors.yellowAccent.withOpacity(0.9),
                                        Colors.orangeAccent,
                                        Colors.yellowAccent.withOpacity(0.9),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(25),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                "Đang chuẩn bị vòng quay cho bạn$_dots",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // Tâm vòng quay (vẫn hiển thị luôn)
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
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Mũi tên chỉ
                const Positioned(
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
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.whatshot_rounded,
                  size: 30,
                  color: const Color.fromARGB(255, 251, 88, 0),
                ),
                SizedBox(width: 8),
                Text(
                  "Điểm danh 3 ngày liên tiếp",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            ),

            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.offline_bolt,
                  size: 28,
                  color: const Color.fromARGB(255, 251, 88, 0),
                ),
                SizedBox(width: 8),
                Text(
                  "1 lượt miễn phí",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                )
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      )),
    );
  }
}

class WheelItem {
  final String label;
  final String emoji;
  final Color color;
  final int id;

  WheelItem(this.label, this.emoji, this.color, this.id);
}

class WheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final Map<String, ui.Image?> images;
  WheelPainter({
    required this.items,
    required this.images,
  });

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

    // ✅ Bỏ saveLayer
    for (int i = 0; i < items.length; i++) {
      final startAngle = (i * anglePerItem - 90) * pi / 180;
      final sweepAngle = anglePerItem * pi / 180;
      final paint = Paint()
        ..color = items[i].color
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..blendMode = BlendMode.src // ✅ Thêm này
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
        ..filterQuality = FilterQuality.high
        ..strokeWidth = 2;

      final dividerEnd = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      canvas.drawLine(center, dividerEnd, dividerPaint);

      final middleAngle = startAngle + sweepAngle / 2;
      final imageRadius = radius * 0.65;
      final imageCenter = Offset(
        center.dx + imageRadius * cos(middleAngle),
        center.dy + imageRadius * sin(middleAngle),
      );

      final image = images[items[i].emoji]; // Lấy ảnh từ URL
      if (image != null) {
        canvas.save();
        canvas.translate(imageCenter.dx, imageCenter.dy);
        canvas.rotate(middleAngle + pi / 2);

        final imageSize = 50.0; // Kích thước ảnh
        final srcRect = Rect.fromLTWH(
            0, 0, image.width.toDouble(), image.height.toDouble());
        final dstRect = Rect.fromCenter(
          center: Offset.zero,
          width: imageSize,
          height: imageSize,
        );

        canvas.drawImageRect(
          image,
          srcRect,
          dstRect,
          Paint()..filterQuality = FilterQuality.high,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) {
    return items != oldDelegate.items;
  }
}
