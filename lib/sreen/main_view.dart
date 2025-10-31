// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/sreen/auth_sreen.dart';
import 'package:spin_app/sreen/history_screen.dart';
import 'package:spin_app/sreen/lucky_wheel_screen.dart';
import 'package:spin_app/models/login_response.dart';
import 'package:spin_app/sreen/streak_sreen.dart';
import 'package:spin_app/utils/admod_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final ProcessController _con = ProcessController();

  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  LoginResponse? userProfile;

  @override
  void initState() {
    super.initState();
    // Giả lập load user
    _checkUserStatus();
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
      userProfile = null;
    });
  }

  void _onLoginTap() async {
    final loggedIn = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );

    if (loggedIn == true) {
      _checkUserStatus();
    }
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences? _prefs = await SharedPreferences.getInstance();
    String? userMap = _prefs.getString('user');
    if (userMap != null) {
      setState(() {
        userProfile = LoginResponse.fromJson(jsonDecode(userMap));
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      LuckyWheelScreen(isUserLoggedIn: _isLoggedIn),
      LibraryTab(
        isLoggedIn: _isLoggedIn,
        history: _isLoggedIn
            ? [
                {
                  'title': '🌟 Vòng quay “Cảm xúc buổi sáng”',
                  'content': 'Bạn mở mắt và thấy ánh nắng đầu ngày xuyên qua khung cửa sổ... '
                      'Một cảm giác bình yên len lỏi trong tâm hồn, khiến bạn mỉm cười nhẹ. '
                      'Hôm nay là một ngày tuyệt vời để bắt đầu điều gì đó mới!',
                },
                {
                  'title': '🌈 Niềm vui bất ngờ',
                  'content':
                      'Bạn không ngờ rằng chỉ một lời chào cũng khiến ai đó vui cả ngày. '
                          'Một hành động nhỏ, nhưng là một dấu ấn đáng nhớ.',
                },
              ]
            : [],
        onLoginTap: _onLoginTap,
      ),
      StreakTab(
        isLoggedIn: _isLoggedIn,
        onLoginTap: _onLoginTap,
        onLogoutTap: _onLogout,
        userId: userProfile?.id,
        userName: userProfile != null ? userProfile!.fullName : "",
      ),
    ];

    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const AdmobView(),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 240, 180),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.deepOrange[700],
                unselectedItemColor: Colors.grey[600],
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
                showUnselectedLabels: true,
                onTap: _onItemTapped,
                items: [
                  _buildItem(Icons.toys_rounded, "Quay"),
                  _buildItem(Icons.auto_stories_rounded, "Thư viện"),
                  _buildItem(Icons.stars_rounded, "Streak"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(icon, size: 30),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 30, color: Colors.deepOrange[700]),
      ),
      label: label,
    );
  }
}
