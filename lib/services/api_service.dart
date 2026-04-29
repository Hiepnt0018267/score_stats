import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import '../models/top_scorer_model.dart';
import '../models/match_detail_model.dart';
import 'user_session.dart';

class ApiService {
  // ✅ VIP PASS: Bỏ qua trang cảnh báo của Ngrok & Định dạng JSON
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      "ngrok-skip-browser-warning": "true",
      "Accept": "application/json",
    },
  ));

  // ==========================================================
  // ⚙️ CÔNG TẮC CHUYỂN ĐỔI MÔI TRƯỜNG
  // - false: Chạy Máy ảo (10.0.2.2)
  // - true: Chạy Điện thoại thật (Ngrok)
  // ==========================================================
  static const bool isProduction = true;

  final String _sofaProxy = isProduction
      ? 'https://untreated-countdown-repulsive.ngrok-free.dev/api/sofascore'
      : 'http://10.0.2.2:8080/api/sofascore';

  final String _myBackend = isProduction
      ? 'https://untreated-countdown-repulsive.ngrok-free.dev/api'
      : 'http://10.0.2.2:8080/api';

  // ==========================================================
  // CÁC HÀM LẤY DỮ LIỆU BÓNG ĐÁ (QUA PROXY SPRING BOOT)
  // ==========================================================

  // 1. Lấy Lịch thi đấu
  Future<List<MatchEvent>> fetchPremierLeagueMatches() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/matches');
      if (response.data == null || response.data
          .toString()
          .isEmpty) return [];

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return MatchResponse
          .fromJson(data)
          .events;
    } catch (e, stacktrace) {
      print('❌ LỖI LỊCH THI ĐẤU: $e');
      print('🔍 DẤU VẾT: $stacktrace');
      return [];
    }
  }

  // 2. Lấy Bảng xếp hạng
  Future<List<StandingRow>> fetchStandings() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/standings');
      if (response.data == null || response.data
          .toString()
          .isEmpty) return [];

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return StandingResponse
          .fromJson(data)
          .rows;
    } catch (e) {
      print('❌ LỖI BẢNG XẾP HẠNG: $e');
      return [];
    }
  }

  // 3. Lấy Vua phá lưới
  Future<List<PlayerStats>> fetchTopScorers() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/top-scorers');
      if (response.data == null || response.data
          .toString()
          .isEmpty) return [];

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      List<dynamic> items = [];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('results') && data['results'] != null) {
          items = data['results'] as List;
        } else
        if (data.containsKey('topPlayers') && data['topPlayers'] != null) {
          items = data['topPlayers'] as List;
        } else
        if (data.containsKey('statistics') && data['statistics'] != null) {
          items = data['statistics'] as List;
        }
      }

      if (items.isNotEmpty) {
        return items.map((item) => PlayerStats.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ LỖI VUA PHÁ LƯỚI: $e');
      return [];
    }
  }

  // 4. Lấy Vua kiến tạo
  Future<List<PlayerStats>> fetchTopAssists() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/top-assists');
      if (response.data == null || response.data
          .toString()
          .isEmpty) return [];

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      List<dynamic> items = [];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('results') && data['results'] != null) {
          items = data['results'] as List;
        } else
        if (data.containsKey('topPlayers') && data['topPlayers'] != null) {
          items = data['topPlayers'] as List;
        } else
        if (data.containsKey('statistics') && data['statistics'] != null) {
          items = data['statistics'] as List;
        }
      }

      if (items.isNotEmpty) {
        return items.map((item) => PlayerStats.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ LỖI VUA KIẾN TẠO: $e');
      return [];
    }
  }

  // 5. Lấy Thống kê trận đấu
  Future<List<MatchStatItem>> fetchMatchStatistics(int matchId) async {
    try {
      final response = await _dio.get('$_sofaProxy/match/$matchId/statistics');
      if (response.data == null) return [];
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return MatchStatisticsResponse
          .fromJson(data)
          .statItems;
    } catch (e) {
      return [];
    }
  }

  // 6. Lấy Đội hình ra sân
  Future<LineupResponse> fetchMatchLineups(int matchId) async {
    try {
      final response = await _dio.get('$_sofaProxy/match/$matchId/lineups');
      if (response.data == null)
        return LineupResponse(homePlayers: [], awayPlayers: []);
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return LineupResponse.fromJson(data);
    } catch (e) {
      return LineupResponse(homePlayers: [], awayPlayers: []);
    }
  }

  // 7. Lấy lịch thi đấu của 1 đội bóng
  Future<List<MatchEvent>> fetchTeamMatches(int teamId, String type) async {
    try {
      final response = await _dio.get('$_sofaProxy/team/$teamId/events/$type');
      if (response.data == null) return [];
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return MatchResponse
          .fromJson(data)
          .events;
    } catch (e) {
      return [];
    }
  }

  // 8. Tìm kiếm đội bóng
  Future<List<dynamic>> searchTeams(String query) async {
    try {
      final response = await _dio.get(
        '$_sofaProxy/search',
        queryParameters: {'q': query},
      );
      if (response.data == null) return [];
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data['results'] != null) {
        final results = data['results'] as List;
        return results
            .where((item) => item['type'] == 'team')
            .map((item) => item['entity'])
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 9. Lấy thông tin chi tiết Cầu thủ
  Future<Map<String, dynamic>?> fetchPlayerInfo(int playerId) async {
    if (playerId == 0) return null;
    try {
      final response = await _dio.get('$_sofaProxy/player/$playerId');
      if (response.data == null) return null;
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data != null && data['player'] != null) {
        return data['player'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==========================================================
  // CÁC HÀM TƯƠNG TÁC VỚI DATABASE CỦA BẠN (MYSQL)
  // ==========================================================

  Future<void> syncUserToBackend(String uid, String email, String name) async {
    try {
      final response = await _dio.post(
        '$_myBackend/users/sync',
        data: {"uid": uid, "email": email, "name": name},
      );
      if (response.statusCode == 200) {
        UserSession.updateUserId(response.data['id']);
      }
    } catch (e) {
      print('❌ LỖI ĐỒNG BỘ USER: $e');
    }
  }

  Future<bool> followTeam(int userId, int apiTeamId, String teamName,
      String logoUrl) async {
    try {
      final response = await _dio.post(
        '$_myBackend/teams/follow',
        data: {
          "userId": userId.toString(),
          "apiId": apiTeamId.toString(),
          "teamName": teamName,
          "logoUrl": logoUrl
        },
      );
      // Chấp nhận cả 200 (OK) và 201 (Created)
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ LỖI FOLLOW ĐỘI BÓNG: $e');
      return false;
    }
  }

  Future<List<dynamic>> getFollowedTeams(int userId) async {
    try {
      final response = await _dio.get('$_myBackend/teams/user/$userId');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('❌ LỖI TẢI DANH SÁCH ĐỘI: $e');
      return [];
    }
  }

  Future<bool> unfollowTeam(int userId, int apiTeamId) async {
    try {
      final response = await _dio.post(
        '$_myBackend/teams/unfollow',
        data: {
          "userId": userId.toString(),
          "apiId": apiTeamId.toString(),
        },
      );
      // Chấp nhận cả 200 (OK) và 204 (No Content)
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ LỖI HỦY FOLLOW: $e');
      return false;
    }
  }
}
