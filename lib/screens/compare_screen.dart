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
  String assetA = 'Bitcoin';
  String assetB = 'Apple';
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
      rate = await CurrencyService.getRate(currency);
      final data = await Future.wait([
        ApiService.fetchHistory(AppConstants.assets[assetA]!, range!.start),
        ApiService.fetchHistory(AppConstants.assets[assetB]!, range!.start),
      ]);

      setState(() {
        statsA = AssetStats.fromRaw(data[0]);
        statsB = AssetStats.fromRaw(data[1]);
        spotsA = AppHelpers.normalizeData(data[0]);
        spotsB = AppHelpers.normalizeData(data[1]);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
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
                ? [const Color(0xFF0F1218), const Color(0xFF1C222D)] 
                : [const Color(0xFFF5F7FA), const Color(0xFFB8C6DB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 24),
                
                // LAYOUT ORIZONTAL: Sidebar Stânga | Grafic Dreapta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SIDEBAR STÂNGA (350px lățime fixă sau flexibil)
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          _buildAssetSelector("Crypto / Stocks Selection"),
                          const SizedBox(height: 20),
                          _buildCalendarCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // GRAFIC DREAPTA
                    Expanded(
                      child: Container(
                        height: 450,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: loading 
                          ? const Center(child: CircularProgressIndicator())
                          : ChartWidget(spotsA: spotsA, spotsB: spotsB, nameA: assetA, nameB: assetB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // STATISTICI SUB TOATE
                if (!loading && spotsA.isNotEmpty)
                  ComparisonTable(
                    statsA: statsA, statsB: statsB,
                    nameA: assetA, nameB: assetB,
                    currency: currency, rate: rate,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white), onPressed: widget.onThemeToggle),
        const Text("MARKET ANALYZER PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: spotsA.isEmpty ? null : () => ShareService.shareAnalysis(
            nameA: assetA,
            nameB: assetB,
            statsA: statsA,
            statsB: statsB,
            currency: currency,
            rate: rate,
            range: range,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetSelector(String title) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            _dropDownAsset(assetA, (v) => setState(() => assetA = v!)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)))),
            _dropDownAsset(assetB, (v) => setState(() => assetB = v!)),
          ],
        ),
      ),
    );
  }

  Widget _dropDownAsset(String current, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: AppConstants.assets.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.calendar_month, color: Colors.indigo),
        title: Text(range == null ? "Selectează Interval" : "${range!.start.day}/${range!.start.month} - ${range!.end.day}/${range!.end.month}"),
        subtitle: const Text("Interval Timp"),
        onTap: () async {
          final r = await showDateRangePicker(context: context, firstDate: DateTime(2023), lastDate: DateTime.now());
          if (r != null) { setState(() => range = r); _fetch(); }
        },
      ),
    );
  }
}