import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/currency_service.dart';
import '../services/share_service.dart';
import '../models/chart_data_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'widgets/multi_chart_widget.dart';
import 'widgets/multi_comparison_table.dart';

class CompareScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const CompareScreen({super.key, required this.onThemeToggle});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<String> selectedAssets = ['Bitcoin (BTC)', 'Apple (AAPL)']; 
  String currency = 'USD';
  double rate = 1.0;
  DateTimeRange? range;
  bool loading = false;

  List<List<FlSpot>> allSpots = [];
  List<AssetStats> allStats = [];
  
  final List<Color> lineColors = [
    Colors.blueAccent, 
    Colors.orangeAccent, 
    Colors.greenAccent, 
    Colors.purpleAccent
  ];

  // Mapare pentru iconițele categoriilor (folosim emoji-uri pentru simplitate)
  final Map<String, String> categoryIcons = {
    'CRYPTO': '₿',
    'TECH STOCKS (USA)': '💻',
    'AUTOMOTIVE & ENERGY': '🚗',
    'INDICES & COMMODITIES': '📈',
    'OTHERS': '⚙️',
  };

  // --- LOGICA PENTRU CATEGORII ÎN DROPDOWN CU ICONIȚE ---
  List<DropdownMenuItem<String>> _buildGroupedItems() {
    List<DropdownMenuItem<String>> menuItems = [];

    AppConstants.categorizedAssets.forEach((category, items) {
      // Preluăm iconița sau folosim una implicită
      final icon = categoryIcons[category] ?? '📂';

      // Adăugăm Header-ul categoriei cu iconiță
      menuItems.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: 'HEADER_$category',
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)), // Iconița
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      );

      // Adăugăm activele din acea categorie
      for (var assetName in items.keys) {
        if (!selectedAssets.contains(assetName)) {
          menuItems.add(
            DropdownMenuItem<String>(
              value: assetName,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(assetName, style: const TextStyle(fontSize: 13)),
              ),
            ),
          );
        }
      }
    });

    return menuItems;
  }

  void _fetch() async {
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alege perioada!")));
      return;
    }
    if (selectedAssets.isEmpty) return;

    setState(() => loading = true);
    try {
      final newRate = await CurrencyService.getRate(currency);
      
      final requests = selectedAssets.map((asset) => 
        ApiService.fetchHistory(AppConstants.assets[asset]!, range!.start)
      ).toList();

      final results = await Future.wait(requests);

      setState(() {
        rate = newRate;
        allStats = results.map((data) => AssetStats.fromRaw(data)).toList();
        allSpots = results.map((data) => AppHelpers.normalizeData(data)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Eroare la preluarea datelor: $e")));
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
            colors: isDark ? [const Color(0xFF0D1117), const Color(0xFF161B22)] : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
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
                    SizedBox(
                      width: 310,
                      child: Column(
                        children: [
                          _buildMultiAssetSelector(isDark),
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
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 380,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: loading 
                              ? const Center(child: CircularProgressIndicator())
                              : allSpots.isEmpty 
                                ? const Center(child: Text("Selectează active și alege perioada pentru a vedea graficul de comparație", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)))
                                : MultiChartWidget(allSpots: allSpots, assetNames: selectedAssets, colors: lineColors),
                          ),
                          const SizedBox(height: 20),
                          if (!loading && allStats.isNotEmpty)
                            MultiComparisonTable(allStats: allStats, names: selectedAssets, currency: currency, rate: rate, colors: lineColors),
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
        Text("MARKET ANALYZER PRO", style: TextStyle(color: isDark ? Colors.white : Colors.indigo[900], fontWeight: FontWeight.w900, fontSize: 18)),
        const SizedBox(width: 8),
        IconButton(icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.orangeAccent : Colors.indigo), onPressed: widget.onThemeToggle),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.share_rounded, color: isDark ? Colors.blueAccent : Colors.indigo),
          onPressed: allStats.isEmpty ? null : () => ShareService.shareMultiAnalysis(names: selectedAssets, stats: allStats, currency: currency, rate: rate, range: range),
        ),
      ],
    );
  }

  Widget _buildMultiAssetSelector(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ACTIVE COMPARATE (MAX 4)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: selectedAssets.asMap().entries.map((entry) {
                return Chip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: lineColors[entry.key % lineColors.length].withOpacity(0.2),
                  onDeleted: () {
                    setState(() {
                      int indexToRemove = entry.key;
                      selectedAssets.removeAt(indexToRemove);
                      if (allSpots.length > indexToRemove) allSpots.removeAt(indexToRemove);
                      if (allStats.length > indexToRemove) allStats.removeAt(indexToRemove);
                    });
                  },
                );
              }).toList(),
            ),
            if (selectedAssets.length < 4) ...[
              const Divider(height: 20),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Adaugă activ...", style: TextStyle(fontSize: 12)),
                  isExpanded: true,
                  items: _buildGroupedItems(), // Implementat cu categorii și iconițe
                  onChanged: (v) {
                    if (v != null && !v.startsWith('HEADER_')) {
                      setState(() => selectedAssets.add(v));
                    }
                  },
                ),
              ),
            ]
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
            const Text("VALUTĂ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currency, isExpanded: true,
                items: AppConstants.currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) { setState(() => currency = v!); _fetch(); },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDark) {
    String txt = range == null ? "Selectează data" : "${range!.start.day}.${range!.start.month} - ${range!.end.day}.${range!.end.month}.${range!.end.year}";
    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: () async {
          final r = await showDateRangePicker(context: context, firstDate: DateTime(2022), lastDate: DateTime.now());
          if (r != null) { setState(() => range = r); _fetch(); }
        },
        title: const Text("PERIOADĂ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        subtitle: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity, height: 55,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.indigoAccent])),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        onPressed: _fetch,
        child: const Text("CALCULEAZĂ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}