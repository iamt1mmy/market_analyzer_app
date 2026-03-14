import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/currency_service.dart';
import '../services/share_service.dart';
import '../models/chart_data_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'widgets/chart_widget.dart';
import 'widgets/comparison_table.dart';

class CompareScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const CompareScreen({super.key, required this.onThemeToggle});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String assetA = 'Bitcoin (BTC)'; 
  String assetB = 'Apple (AAPL)';
  String currency = 'USD';
  double rate = 1.0;
  DateTimeRange? range;
  bool loading = false;

  List<FlSpot> spotsA = [];
  List<FlSpot> spotsB = [];
  AssetStats statsA = AssetStats.empty();
  AssetStats statsB = AssetStats.empty();

  void _fetch() async {
    if (range == null) return;
    setState(() => loading = true);
    try {
      final newRate = await CurrencyService.getRate(currency);
      final data = await Future.wait([
        ApiService.fetchHistory(AppConstants.assets[assetA]!, range!.start),
        ApiService.fetchHistory(AppConstants.assets[assetB]!, range!.start),
      ]);

      setState(() {
        rate = newRate;
        statsA = AssetStats.fromRaw(data[0]);
        statsB = AssetStats.fromRaw(data[1]);
        spotsA = AppHelpers.normalizeData(data[0]);
        spotsB = AppHelpers.normalizeData(data[1]);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Eroare: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF0D1117), const Color(0xFF161B22)] 
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SIDEBAR (Stânga) ---
                    SizedBox(
                      width: 310,
                      child: Column(
                        children: [
                          _buildAssetSelector(isDark),
                          const SizedBox(height: 12),
                          _buildCurrencyCard(isDark),
                          const SizedBox(height: 12),
                          _buildCalendarCard(isDark),
                          const SizedBox(height: 20),
                          _buildAnalyzeButton(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // --- ZONA CENTRALĂ (Grafic + Statistici sub el) ---
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 380, 
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.white),
                            ),
                            child: loading 
                              ? const Center(child: CircularProgressIndicator())
                              : spotsA.isEmpty 
                                ? const Center(child: Text("Configurează analiza din stânga"))
                                : ChartWidget(
                                    spotsA: spotsA, spotsB: spotsB, 
                                    nameA: assetA, nameB: assetB,
                                    statsA: statsA, statsB: statsB,
                                  ),
                          ),
                          const SizedBox(height: 20),
                          if (!loading && spotsA.isNotEmpty)
                            ComparisonTable(
                              statsA: statsA, statsB: statsB,
                              nameA: assetA, nameB: assetB,
                              currency: currency, rate: rate,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
          color: isDark ? Colors.orangeAccent : Colors.indigo), 
          onPressed: widget.onThemeToggle
        ),
        const SizedBox(width: 8),
        Text(
          "MARKET ANALYZER PRO", 
          style: TextStyle(
            color: isDark ? Colors.white : Colors.indigo[900], 
            fontWeight: FontWeight.w900, 
            letterSpacing: 1.5, 
            fontSize: 18
          )
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.share_rounded, color: isDark ? Colors.blueAccent : Colors.indigo, size: 20),
          onPressed: spotsA.isEmpty ? null : () => ShareService.shareAnalysis(
            nameA: assetA, nameB: assetB, statsA: statsA, statsB: statsB,
            currency: currency, rate: rate, range: range,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetSelector(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ACTIVE PENTRU COMPARARE", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            _dropDownAsset(assetA, (v) => setState(() => assetA = v!)),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4), 
                child: Text("VS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12))
              ),
            ),
            _dropDownAsset(assetB, (v) => setState(() => assetB = v!)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("VALUTĂ AFIȘARE", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)),
            Row(
              children: [
                const Icon(Icons.currency_exchange, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currency,
                      isExpanded: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      items: AppConstants.currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) {
                        setState(() => currency = v!);
                        _fetch();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDark) {
    String dateRangeText = range == null 
        ? "Alege intervalul" 
        : "${range!.start.day}.${range!.start.month}.${range!.start.year} - ${range!.end.day}.${range!.end.month}.${range!.end.year}";

    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final r = await showDateRangePicker(context: context, firstDate: DateTime(2022), lastDate: DateTime.now());
          if (r != null) { setState(() => range = r); _fetch(); }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("PERIOADĂ ANALIZATĂ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 10),
                  Text(dateRangeText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.indigoAccent]),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _fetch,
        child: const Text("CALCULEAZĂ PERFORMANȚA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _dropDownAsset(String current, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: AppConstants.assets.keys.map((s) => DropdownMenuItem(
          value: s, 
          child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}