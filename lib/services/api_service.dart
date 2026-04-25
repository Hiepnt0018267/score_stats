import 'package:dio/dio.dart';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import '../models/top_scorer_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _apiKey = 'YOUR_API_KEY_HERE';

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
}
