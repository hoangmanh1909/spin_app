import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobView extends StatefulWidget {
  const AdmobView({super.key});

  // 👉 Dùng ID TEST chính chủ từ Google (an toàn khi dev)
  static const String androidTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosTestId = 'ca-app-pub-3940256099942544/2934735716';

  @override
  State<StatefulWidget> createState() => _AdmobViewState();
}

class _AdmobViewState extends State<AdmobView> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adUnitId =
        Platform.isAndroid ? AdmobView.androidTestId : AdmobView.iosTestId;

    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('⚠️ Banner failed to load: $error');
          _isLoaded = false;
          ad.dispose();
          // 🕓 Thử load lại sau 10s
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted) _loadBanner();
          });
        },
      ),
    );

    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🪄 Không chiếm chỗ nếu chưa load
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _isLoaded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _bannerAd!.size.height.toDouble(),
            width: _bannerAd!.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      ),
    );
  }
}
