import 'package:dio/dio.dart';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import '../models/top_scorer_model.dart';
import '../models/match_detail_model.dart';
class ApiService {
  final Dio _dio = Dio();
  final String _apiKey = 'fd019d9933mshc70adffe45c288cp1728e1jsncad191f24366';

  // Hàm 1: Lấy Lịch thi đấu (Cũ)
  Future<List<MatchEvent>> fetchPremierLeagueMatches() async {
    try {
      final response = await _dio.get(
        'https://sofascore.p.rapidapi.com/tournaments/get-last-matches',
        queryParameters: {
          'tournamentId': 17,
          'seasonId': 76986,
          'pageIndex': 0,
        },
        options: Options(
          headers: {
            'x-rapidapi-host': 'sofascore.p.rapidapi.com',
            'x-rapidapi-key': _apiKey,
          },
        ),
      );
      return MatchResponse.fromJson(response.data).events;
    } catch (e) {
      throw Exception('Không thể tải lịch thi đấu');
    }
  }

  // Hàm 2: Lấy Bảng xếp hạng (Mới)
  Future<List<StandingRow>> fetchStandings() async {
    try {
      final response = await _dio.get(
        'https://sofascore.p.rapidapi.com/tournaments/get-standings',
        queryParameters: {
          'tournamentId': 17,
          'seasonId': 76986,
          'type': 'total',
          // Bảng xếp hạng tổng (không phải riêng sân nhà/sân khách)
        },
        options: Options(
          headers: {
            'x-rapidapi-host': 'sofascore.p.rapidapi.com',
            'x-rapidapi-key': _apiKey,
          },
        ),
      );
      return StandingResponse.fromJson(response.data).rows;
    } catch (e) {
      print('Lỗi gọi mạng BXH: $e');
      throw Exception('Không thể tải Bảng xếp hạng');
    }
  }

  Future<List<PlayerStats>> fetchTopScorers() async {
    try {
      final response = await _dio.get(
        'https://sofascore.p.rapidapi.com/tournaments/get-top-players',
        // Link mới
        queryParameters: {'tournamentId': 17, 'seasonId': 76986},
        options: Options(
          headers: {
            'x-rapidapi-host': 'sofascore.p.rapidapi.com',
            'x-rapidapi-key': _apiKey,
          },
        ),
      );
      return TopScorerResponse.fromJson(response.data).goals;
    } catch (e) {
      print('Lỗi gọi mạng Vua phá lưới: $e');
      throw Exception('Không thể tải dữ liệu Vua phá lưới');
    }
  }
  // Hàm 4: Lấy Thống kê trận đấu
  Future<List<MatchStatItem>> fetchMatchStatistics(int matchId) async {
    try {
      final response = await _dio.get(
        'https://sofascore.p.rapidapi.com/matches/get-statistics',
        queryParameters: {'matchId': matchId},
        options: Options(headers: {'x-rapidapi-host': 'sofascore.p.rapidapi.com', 'x-rapidapi-key': _apiKey}),
      );
      return MatchStatisticsResponse.fromJson(response.data).statItems;
    } catch (e) {
      print('Lỗi gọi Thống kê: $e');
      return []; // Nếu lỗi (ví dụ trận chưa đá không có thống kê) thì trả về mảng rỗng
    }
  }

  // Hàm 5: Lấy Đội hình ra sân
  Future<LineupResponse> fetchMatchLineups(int matchId) async {
    try {
      final response = await _dio.get(
        'https://sofascore.p.rapidapi.com/matches/get-lineups',
        queryParameters: {'matchId': matchId},
        options: Options(headers: {'x-rapidapi-host': 'sofascore.p.rapidapi.com', 'x-rapidapi-key': _apiKey}),
      );
      return LineupResponse.fromJson(response.data);
    } catch (e) {
      print('Lỗi gọi Đội hình: $e');
      return LineupResponse(homePlayers: [], awayPlayers: []);
    }
  }
}
