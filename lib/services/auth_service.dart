// File: lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart'; // Import ApiService
import 'user_session.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. Kiểm tra xem có ai đang đăng nhập không
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 2. Hàm xử lý Đăng nhập Google + Đồng bộ Backend
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // --- ĐOẠN MỚI THÊM VÀO ---
      // Nếu Firebase đăng nhập thành công, lập tức báo cho Spring Boot!
      if (user != null) {
        await ApiService().syncUserToBackend(
          user.uid,
          user.email ?? "no-email@gmail.com",
          user.displayName ?? "Khách",
        );
      }
      // -------------------------

      return user;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return null;
    }
  }

  // 3. Hàm Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    UserSession.mySqlUserId = null;
    print("Đã đăng xuất và xóa bộ nhớ tạm!");
  }

  // 4. HÀM MỚI: Khôi phục phiên làm việc khi mở app
  // (Phòng trường hợp hôm qua người dùng đã đăng nhập rồi, hôm nay mở app lên lại)
  Future<void> restoreSession() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print("Phát hiện user cũ, đang kết nối lại với Spring Boot...");
      await ApiService().syncUserToBackend(
        user.uid,
        user.email ?? "no-email@gmail.com",
        user.displayName ?? "Khách",
      );
    }
  }
}