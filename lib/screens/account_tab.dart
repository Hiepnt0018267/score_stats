// File: lib/screens/account_tab.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Vừa vào Tab là kiểm tra ngay xem có ai đang đăng nhập không
    _currentUser = _authService.getCurrentUser();
  }

  // Lệnh chạy khi bấm nút Đăng nhập
  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    final user = await _authService.signInWithGoogle();

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  // Lệnh chạy khi bấm nút Đăng xuất
  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);

    await _authService.signOut();

    setState(() {
      _currentUser = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3C1C5A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3C1C5A)))
          : _currentUser == null
          ? _buildLoginView()
          : _buildProfileView(),
    );
  }

  // GIAO DIỆN KHI CHƯA ĐĂNG NHẬP
  Widget _buildLoginView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'Đăng nhập để theo dõi đội bóng yêu thích\nvà không bỏ lỡ trận đấu nào!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _handleSignIn,
            icon: const Icon(Icons.login),
            label: const Text('Đăng nhập bằng Google', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE90052),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  // GIAO DIỆN KHI ĐÃ ĐĂNG NHẬP
  Widget _buildProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiện Avatar từ Google
          CircleAvatar(
            radius: 50,
            backgroundImage: _currentUser!.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
            child: _currentUser!.photoURL == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 20),
          Text(
            _currentUser!.displayName ?? 'Người dùng Ẩn danh',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser!.email ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}