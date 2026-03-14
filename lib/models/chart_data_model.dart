class AssetStats {
  final double startPrice;
  final double endPrice;
  final double performance;
  final double minPrice;
  final double maxPrice;

  AssetStats({
    required this.startPrice,
    required this.endPrice,
    required this.performance,
    required this.minPrice,
    required this.maxPrice,
  });

  factory AssetStats.fromRaw(List<dynamic> raw) {
    if (raw.isEmpty) return AssetStats.empty();
    
    // REPARARE: Conversie forțată la String înainte de parse pentru a evita TypeError
    List<double> allPrices = raw.map((e) => double.parse(e['close'].toString())).toList();
    
    double s = allPrices.first;
    double e = allPrices.last;
    double perf = ((e - s) / s) * 100;
    double min = allPrices.reduce((a, b) => a < b ? a : b);
    double max = allPrices.reduce((a, b) => a > b ? a : b);

    return AssetStats(
      startPrice: s,
      endPrice: e,
      performance: perf,
      minPrice: min,
      maxPrice: max,
    );
  }

  factory AssetStats.empty() => AssetStats(
    startPrice: 0, 
    endPrice: 0, 
    performance: 0, 
    minPrice: 0, 
    maxPrice: 0
  );
}