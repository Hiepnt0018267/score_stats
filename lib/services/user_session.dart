// File: lib/services/user_session.dart (Hoặc đường dẫn tương ứng của bạn)
import 'package:flutter/foundation.dart'; // Thêm dòng này để dùng ValueNotifier

class UserSession {
  static int? mySqlUserId;

  // 1. Thêm cái chuông báo này vào
  static ValueNotifier<int?> userIdNotifier = ValueNotifier(null);
  static ValueNotifier<int> followChangeNotifier = ValueNotifier(0);

  // 2. Thêm hàm này để cập nhật ID và rung chuông
  static void updateUserId(int? id) {
    mySqlUserId = id;
    userIdNotifier.value = id; // Rung chuông báo cho UI biết!
  }
  static void triggerFollowUpdate() {
    followChangeNotifier.value++;
  }
}