import 'package:flutter/material.dart';
import '../models/match_detail_model.dart';

class StatsTabWidget extends StatelessWidget {
  final List<MatchStatItem> stats;

  const StatsTabWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('Chưa có thống kê cho trận này.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(stat.homeValue, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                flex: 2,
                child: Text(stat.name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              ),
              Expanded(
                child: Text(stat.awayValue, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}