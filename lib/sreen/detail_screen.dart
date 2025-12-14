import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/response_object.dart';

class StoryDetailScreen extends StatefulWidget {
  final String story;
  final String title;
  final int? userId;
  const StoryDetailScreen(
      {super.key, required this.story, required this.title, this.userId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool loading = true;
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  int _spinsLeft = 0;
  final ProcessController _con = ProcessController();
  @override
  void initState() {
    super.initState();
    loading = false;
  }

  void _loadRewardedAd() {
    setState(() => _isAdLoading = true);

    RewardedAd.load(
      adUnitId: 'ca-app-pub-4615980675698382/3961517652', // ID thật của bro
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          setState(() => _isAdLoading = false);
          _showRewardedAd();
        },
        onAdFailedToLoad: (error) {
          setState(() => _isAdLoading = false);
          _showAdFailedPopup();
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      _showAdFailedPopup();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        setState(() => _spinsLeft += 1);
        _onSpinUpdated(_spinsLeft);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Bạn nhận thêm 1 lượt quay!')),
        );
      },
    );
  }

  void _onSpinUpdated(int newCount) async {
    if (widget.userId == null) return;
    ResponseObject res = await _con.changeNumberOfTurn(widget.userId!, 1);

    if (res.code == "00") {
      if (!mounted) return;
      setState(() {
        _spinsLeft = newCount;
      });
    }
  }

  void _showAdFailedPopup() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Quảng cáo chưa sẵn sàng"),
          content: const Text(
            "Hiện tại không có quảng cáo nào để hiển thị. Tính năng vẫn khả dụng, nhưng quảng cáo có thể xuất hiện không thường xuyên.",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              child: const Text("Đóng"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          "Khoảnh khắc của bạn",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                              widget.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.story,
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

            // const SizedBox(height: 24),

            // // Nút xem quảng cáo
            // SizedBox(
            //     width: double.infinity,
            //     height: 52,
            //     child: OutlinedButton.icon(
            //       onPressed: _isAdLoading ? null : _loadRewardedAd,
            //       icon: _isAdLoading
            //           ? const SizedBox(
            //               width: 22,
            //               height: 22,
            //               child: CircularProgressIndicator(
            //                 strokeWidth: 2.5,
            //                 color: Colors.black54,
            //               ),
            //             )
            //           : const Icon(Icons.play_circle_outline),
            //       label: Text(
            //         _isAdLoading
            //             ? "Đang tải quảng cáo..."
            //             : "Xem quảng cáo nhận lượt quay",
            //         style: const TextStyle(
            //             fontSize: 15, fontWeight: FontWeight.w500),
            //       ),
            //       style: OutlinedButton.styleFrom(
            //         side: const BorderSide(color: Colors.black26),
            //         foregroundColor: Colors.black87,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(30),
            //         ),
            //       ),
            //     ))
          ],
        ),
      ),
    );
  }
}
