// File: lib/widgets/match_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../screens/match_detail_screen.dart';
import '../services/api_service.dart'; // Import để lấy Link động

class MatchCard extends StatelessWidget {
  final MatchEvent match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final homeScore = match.homeScore?.display?.toString() ?? '?';
    final awayScore = match.awayScore?.display?.toString() ?? '?';

    // ✅ TỰ ĐỘNG LẤY LINK NGROK HAY MÁY ẢO DỰA VÀO CÔNG TẮC BÊN API_SERVICE
    final String imageHost = ApiService.isProduction
        ? 'https://untreated-countdown-repulsive.ngrok-free.dev'
        : 'http://10.0.2.2:8080';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(match: match),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ĐỘI NHÀ
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: '$imageHost/api/sofascore/team-logo/${match.homeTeam.id}', // Đã đổi sang Link động
                      httpHeaders: const {"ngrok-skip-browser-warning": "true"}, // ✅ THÊM THẺ VIP VƯỢT NGROK
                      width: 45, height: 45,
                      placeholder: (context, url) => const SizedBox(width: 45, height: 45, child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Icon(Icons.shield, size: 45, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(match.homeTeam.shortName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              // TỈ SỐ
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text('$homeScore - $awayScore', style: const TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      match.status.description,
                      style: TextStyle(
                          color: match.status.description == 'Ended' ? Colors.red[700] : Colors.grey[600],
                          fontSize: 12, fontWeight: FontWeight.w500
                      ),
                    ),
                  ],
                ),
              ),
              // ĐỘI KHÁCH
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: '$imageHost/api/sofascore/team-logo/${match.awayTeam.id}', // Đã đổi sang Link động
                      httpHeaders: const {"ngrok-skip-browser-warning": "true"}, // ✅ THÊM THẺ VIP VƯỢT NGROK
                      width: 45, height: 45,
                      placeholder: (context, url) => const SizedBox(width: 45, height: 45, child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Icon(Icons.shield, size: 45, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(match.awayTeam.shortName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}