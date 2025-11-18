// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/history_response.dart';
import 'package:spin_app/models/response_object.dart';
import 'package:spin_app/sreen/auth_sreen.dart';
import 'package:spin_app/sreen/feed_screen.dart';
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
  List<GetHistoryResponse> history = [];

  @override
  void initState() {
    super.initState();
    // Giả lập load user
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    SharedPreferences? _prefs = await SharedPreferences.getInstance();
    String? userMap = _prefs.getString('user');
    if (userMap != null) {
      setState(() {
        userProfile = LoginResponse.fromJson(jsonDecode(userMap));
        _isLoggedIn = true;
      });
      await getHistory();
    }
  }

  void _onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    setState(() {
      _isLoggedIn = false;
      userProfile = null;
    });
  }

  void _onRemoveUser() async {
    ResponseObject resp =
        await _con.removeUser(userProfile != null ? userProfile!.id : 0);
    if (resp.code == "00") {
      SharedPreferences? _prefs = await SharedPreferences.getInstance();
      await _prefs.remove('user');
      setState(() {
        _isLoggedIn = false;
        userProfile = null;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xoá tài khoản thành công'),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xoá tài khoản thất bại: ${resp.message}'),
          ),
        );
      }
    }
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

  void _refreshHistory() async {
    await getHistory();

    setState(() {});
  }

  getHistory() async {
    if (userProfile != null) {
      var resp = await _con.getHistoryByUser(userProfile!.id);
      if (resp.code == "00") {
        history = List<GetHistoryResponse>.from((jsonDecode(resp.data!)
            .map((model) => GetHistoryResponse.fromJson(model))));
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      LuckyWheelScreen(
          key: ValueKey(_isLoggedIn),
          isUserLoggedIn: _isLoggedIn,
          userId: userProfile?.id,
          onLoginStateChanged: (bool loggedIn) {
            _checkUserStatus();
          },
          onHistoryAdded: _refreshHistory),
      LibraryTab(
        key: ValueKey(history.length),
        isLoggedIn: _isLoggedIn,
        history: history,
        onLoginTap: _onLoginTap,
      ),
      FeedScreen(),
      StreakTab(
        key: ValueKey(_isLoggedIn),
        isLoggedIn: _isLoggedIn,
        onLoginTap: _onLoginTap,
        onLogoutTap: _onLogout,
        onRemoveUserTap: _onRemoveUser,
        userId: userProfile?.id,
        userName: userProfile != null ? userProfile!.fullName : "",
      ),
    ];

    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdmobView(),
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
                  _buildItem(Icons.public_rounded, "Khám phá"),
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
