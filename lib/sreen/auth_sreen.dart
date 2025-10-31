import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spin_app/controller/process_controller.dart';
import 'package:spin_app/models/add_user_request.dart';
import 'package:spin_app/models/login_request.dart';
import 'package:spin_app/models/login_response.dart';
import 'package:spin_app/models/response_object.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProcessController _con = ProcessController();
  SharedPreferences? prefs;

  bool _isLoading = false;

  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();

  final _regUser = TextEditingController();
  final _regName = TextEditingController();
  final _regPass = TextEditingController();
  final _regPassAgain = TextEditingController();

  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {}); // nếu bạn cần rebuild UI khi prefs sẵn sàng
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  /// 🧠 Xử lý Đăng nhập
  Future<void> _handleLogin() async {
    if (!_formKeyLogin.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      LoginRequest req = LoginRequest();
      req.userName = _loginUser.text;
      req.password = _loginPass.text;
      ResponseObject res = await _con.login(req);

      if (res.code == "00") {
        prefs!.setString('user', res.data!);
        prefs!.setString('accessToken', res.accessToken!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Đăng nhập thành công!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Sai tài khoản hoặc mật khẩu')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Lỗi mạng: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🧠 Xử lý Đăng ký
  Future<void> _handleRegister() async {
    if (!_formKeyRegister.currentState!.validate()) return;

    if (_regPass.text != _regPassAgain.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Mật khẩu nhập lại không khớp')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      AddUserRequest req = AddUserRequest();
      req.userName = _regUser.text;
      req.password = _regPass.text;
      req.fullName = _regName.text;
      ResponseObject res = await _con.addUser(req);

      if (res.code == "00") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Tạo tài khoản thành công!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Đăng ký thất bại (${res.message})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Lỗi kết nối: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 240, 189, 22)),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.auto_awesome, size: 72, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                "SpinStory ✨",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.amber[800],
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.amber[700],
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        tabs: const [
                          Tab(text: 'Đăng nhập'),
                          Tab(text: 'Đăng ký'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginForm(),
                            _buildRegisterForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔑 Form đăng nhập
  Widget _buildLoginForm() {
    return Form(
      key: _formKeyLogin,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField(
              controller: _loginUser,
              label: 'Tên đăng nhập',
              icon: Icons.person,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _loginPass,
              label: 'Mật khẩu',
              icon: Icons.lock,
              obscure: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 28),
            _buildButton('Đăng nhập', _handleLogin),
            if (_isLoading)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  /// 🧾 Form đăng ký
  Widget _buildRegisterForm() {
    return Form(
      key: _formKeyRegister,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField(
              controller: _regUser,
              label: 'Tên đăng nhập',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
            ),
            const SizedBox(height: 10),
            _buildField(
              controller: _regName,
              label: 'Họ và tên',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 10),
            _buildField(
              controller: _regPass,
              label: 'Mật khẩu',
              icon: Icons.lock_outline,
              obscure: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 10),
            _buildField(
              controller: _regPassAgain,
              label: 'Nhập lại mật khẩu',
              icon: Icons.lock_outline,
              obscure: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập lại mật khẩu' : null,
            ),
            const SizedBox(height: 18),
            _buildButton('Tạo tài khoản', _handleRegister),
            if (_isLoading)
              const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        cursorColor: Colors.amber[700],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.amber[700]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.amber[700]!, width: 1.2),
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
