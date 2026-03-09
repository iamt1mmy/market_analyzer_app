import '../utils/helpers.dart';

class AssetStats {
  final double startPrice;
  final double endPrice;
  final double performance;

  AssetStats({
    required this.startPrice,
    required this.endPrice,
    required this.performance,
  });

  factory AssetStats.fromRaw(List<dynamic> raw) {
    if (raw.isEmpty) return AssetStats.empty();
    
    double s = double.parse(raw.first['close']);
    double e = double.parse(raw.last['close']);
    
    // Calculăm performanța brută
    double perf = ((e - s) / s) * 100;

    return AssetStats(
      startPrice: s,
      endPrice: e,
      performance: perf,
    );
  }

  factory AssetStats.empty() => AssetStats(startPrice: 0, endPrice: 0, performance: 0);
}