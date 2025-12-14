import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/change_password_request.dart';
import 'package:spin_app/models/get_checkin_streak_response.dart';
import 'package:spin_app/models/response_object.dart';

class StreakTab extends StatefulWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? avatarUrl;
  final int? userId;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onRemoveUserTap;

  const StreakTab(
      {super.key,
      required this.isLoggedIn,
      this.userName,
      this.avatarUrl,
      this.userId,
      this.onLoginTap,
      this.onLogoutTap,
      this.onRemoveUserTap});

  @override
  State<StreakTab> createState() => _StreakTabState();
}

class _StreakTabState extends State<StreakTab> {
  final ProcessController _con = ProcessController();
  int _spinsLeft = 0;
  int _streakDays = 0;
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _checkedInToday = false;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    if (widget.userId == null) return;
    ResponseObject res = await _con.getCheckinStreak(widget.userId!);
    if (res.code == "00") {
      GetCheckinStreakResponse streakRes =
          GetCheckinStreakResponse.fromJson(jsonDecode(res.data!));
      if (mounted) {
        setState(() {
          _streakDays = streakRes.checkinStreak!;
          _checkedInToday = streakRes.checkDate! == 0 ? false : true;
          _spinsLeft = streakRes.numberOfTurn!;
        });
      }
    }
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

  Future<void> _handleCheckIn() async {
    if (_checkedInToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Bạn đã điểm danh hôm nay rồi!')),
      );
      return;
    }
    if (widget.userId != null) {
      ResponseObject res = await _con.checkin(widget.userId!);
      if (res.code != "00") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Điểm danh thất bại: ${res.message}')),
          );
        }
        return;
      }

      setState(() {
        _checkedInToday = true;
        _streakDays += 1;
        _spinsLeft += int.parse(res.data!);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Điểm danh thành công!')),
        );
      }
    }
  }

  void _loadRewardedAd() {
    setState(() => _isAdLoading = true);

    RewardedAd.load(
<<<<<<< HEAD
      adUnitId: 'ca-app-pub-4615980675698382/7581011115',
=======
      adUnitId: 'ca-app-pub-4615980675698382/3961517652', // ID thật của bro
>>>>>>> 09fa4ea (1)
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
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 189, 22),
      ),
      child: widget.isLoggedIn ? _buildLoggedInUI() : _buildGuestUI(),
    );
  }

  Widget _buildGuestUI() {
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
                'Đăng nhập để xem số lượt quay và nhận thêm phần thưởng 🎯',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onLoginTap,
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

  Widget _buildLoggedInUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Header user info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar + Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: widget.avatarUrl != null
                          ? NetworkImage(widget.avatarUrl!)
                          : const AssetImage(
                                  'assets/img/avatar_placeholder.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName ?? 'Người chơi bí ẩn',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Chào một ngày mới thật rực rỡ 🌈',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Nút cài đặt
                IconButton(
                  icon:
                      const Icon(Icons.settings, color: Colors.grey, size: 36),
                  onPressed: () {
                    _showSettingSheet(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Spins card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Lượt quay còn lại',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_spinsLeft',
                    style: const TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // ElevatedButton.icon(
                  //   onPressed: _isAdLoading ? null : _loadRewardedAd,
                  //   icon: const Icon(Icons.ondemand_video, color: Colors.white),
                  //   label: Text(
                  //     _isAdLoading
                  //         ? 'Đang tải quảng cáo...'
                  //         : 'Xem để nhận thêm lượt quay',
                  //     style: const TextStyle(color: Colors.white),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.orange.shade600,
                  //     minimumSize: const Size(double.infinity, 52),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(28),
                  //     ),
                  //     elevation: 0,
                  //     textStyle: const TextStyle(
                  //         fontSize: 16, fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Streak progress + Check-in
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Chuỗi ngày điểm danh 💥',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_streakDays % 3) / 3,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Text('$_streakDays ngày liên tiếp, cố lên bạn nhé! 💪'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkedInToday ? null : _handleCheckIn,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _checkedInToday
                            ? Colors.grey
                            : Colors.orange.shade600,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0),
                    child: Text(
                      _checkedInToday
                          ? 'Đã điểm danh hôm nay'
                          : 'Điểm danh ngay',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // để tạo nền mờ phía sau
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo trên cùng
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Center(
                child: Text(
                  'Cài đặt tài khoản',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),

              // Các mục chức năng
              _buildSettingItem(
                icon: Icons.lock_outline,
                text: 'Đổi mật khẩu',
                onTap: () {
                  Navigator.pop(context);

                  _showChangePasswordModal(context, parentContext: context);
                },
              ),
              // _buildSettingItem(
              //   icon: Icons.support_agent_outlined,
              //   text: 'Liên hệ hỗ trợ',
              //   onTap: () {},
              // ),
              _buildSettingItem(
                icon: Icons.logout,
                text: 'Đăng xuất',
                onTap: () {
                  Navigator.pop(context);

                  widget.onLogoutTap?.call();
                },
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                text: 'Xóa tài khoản',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);

                  _showDeleteAccountConfirm(context, parentContext: context);
                },
              ),
              const Divider(height: 24),

              // Nút đóng
              SafeArea(
                top: false,
                child: Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context,
      {required BuildContext parentContext}) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: currentController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Mật khẩu hiện tại',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        labelText: 'Mật khẩu mới',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.check_circle_outline),
                        labelText: 'Xác nhận mật khẩu mới',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final current = currentController.text.trim();
                          final newPass = newController.text.trim();
                          final confirm = confirmController.text.trim();

                          if (current.isEmpty ||
                              newPass.isEmpty ||
                              confirm.isEmpty) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập đầy đủ thông tin'),
                              ),
                            );
                            return;
                          }

                          if (newPass != confirm) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                content: Text('Mật khẩu xác nhận không khớp'),
                              ),
                            );
                            return;
                          }

                          if (widget.userId != null) {
                            ChangePasswordRequest req = ChangePasswordRequest(
                              id: widget.userId!,
                              currentPassword: current,
                              newPassword: confirm,
                            );
                            ResponseObject res = await _con.changePassword(req);

                            if (res.code != "00") {
                              if (mounted) {
                                Flushbar(
                                  message:
                                      'Đổi mật khẩu thất bại: ${res.message}',
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 4),
                                  margin: const EdgeInsets.all(8),
                                  borderRadius: BorderRadius.circular(12),
                                ).show(context);
                              }
                            } else {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(parentContext)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text('Đổi mật khẩu thành công!'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }

  void _showDeleteAccountConfirm(BuildContext context,
      {required BuildContext parentContext}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo nhỏ trên cùng (chuẩn iOS)
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),

              const Text(
                'Xóa tài khoản?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Hành động này sẽ xóa vĩnh viễn tất cả dữ liệu của bạn và không thể khôi phục.\nBạn có chắc chắn muốn tiếp tục?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Nút Xóa
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Đóng modal xác nhận

                    widget.onRemoveUserTap?.call();
                  },
                  child: const Text(
                    'Xóa tài khoản',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Nút hủy
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
