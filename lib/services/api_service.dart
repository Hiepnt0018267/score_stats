import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import '../models/top_scorer_model.dart';
import '../models/match_detail_model.dart';
import 'user_session.dart';

class ApiService {
  final Dio _dio = Dio();

  // --- BASE URL ---
  // Trỏ về Backend Spring Boot của bạn để tránh lỗi 429
  final String _sofaProxy = 'http://10.0.2.2:8080/api/sofascore';
  final String _myBackend = 'http://10.0.2.2:8080/api';

  // ==========================================================
  // CÁC HÀM LẤY DỮ LIỆU BÓNG ĐÁ (QUA PROXY SPRING BOOT)
  // ==========================================================

  // 1. Lấy Lịch thi đấu
  Future<List<MatchEvent>> fetchPremierLeagueMatches() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/matches');
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      return MatchResponse.fromJson(data).events;
    } catch (e) {
      throw Exception('Khong the tai lich thi dau');
    }
  }

  // 2. Lấy Bảng xếp hạng
  Future<List<StandingRow>> fetchStandings() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/standings');
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      return StandingResponse.fromJson(data).rows;
    } catch (e) {
      throw Exception('Khong the tai Bang xep hang');
    }
  }

  Future<List<PlayerStats>> fetchTopScorers() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/top-scorers');
      final data = response.data is String ? jsonDecode(response.data) : response.data;

      // API /statistics trả về mảng trong mục 'results'
      if (data['results'] != null) {
        print('🔍 ITEM MẪU: ${data['results'][0]}');
        return (data['results'] as List).map((item) => PlayerStats.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi Vua phá lưới: $e');
      return [];
    }
  }

  Future<List<PlayerStats>> fetchTopAssists() async {
    try {
      final response = await _dio.get('$_sofaProxy/league/17/top-assists');
      final data = response.data is String ? jsonDecode(response.data) : response.data;

      if (data['results'] != null) {
        print('🔍 ITEM MẪU: ${data['results'][0]}');
        return (data['results'] as List).map((item) => PlayerStats.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi Vua kiến tạo: $e');
      return [];
    }
  }

  // 5. Lấy Thống kê trận đấu
  Future<List<MatchStatItem>> fetchMatchStatistics(int matchId) async {
    try {
      final response = await _dio.get('$_sofaProxy/match/$matchId/statistics');
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      return MatchStatisticsResponse.fromJson(data).statItems;
    } catch (e) {
      return [];
    }
  }

  // 6. Lấy Đội hình ra sân
  Future<LineupResponse> fetchMatchLineups(int matchId) async {
    try {
      final response = await _dio.get('$_sofaProxy/match/$matchId/lineups');
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      return LineupResponse.fromJson(data);
    } catch (e) {
      return LineupResponse(homePlayers: [], awayPlayers: []);
    }
  }

  // 7. Lấy lịch thi đấu của 1 đội bóng (Đã đá & Sắp đá)
  Future<List<MatchEvent>> fetchTeamMatches(int teamId, String type) async {
    try {
      final response = await _dio.get('$_sofaProxy/team/$teamId/events/$type');
      final data = response.data is String ? jsonDecode(response.data) : response.data;
      return MatchResponse.fromJson(data).events;
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
      final data = response.data is String ? jsonDecode(response.data) : response.data;

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
      final data = response.data is String ? jsonDecode(response.data) : response.data;

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

  // Đồng bộ User với Backend
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
      // Bỏ qua log lỗi
    }
  }

  // Theo dõi đội bóng
  Future<bool> followTeam(int userId, int apiTeamId, String teamName, String logoUrl) async {
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
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Lấy danh sách đội bóng đã Follow
  Future<List<dynamic>> getFollowedTeams(int userId) async {
    try {
      final response = await _dio.get('$_myBackend/teams/user/$userId');
      return response.statusCode == 200 ? response.data : [];
    } catch (e) {
      return [];
    }
  }

  // Bỏ theo dõi đội bóng
  Future<bool> unfollowTeam(int userId, int apiTeamId) async {
    try {
      final response = await _dio.post(
        '$_myBackend/teams/unfollow',
        data: {
          "userId": userId.toString(),
          "apiId": apiTeamId.toString(),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}