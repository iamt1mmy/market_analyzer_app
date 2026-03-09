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
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Te rugăm să selectezi mai întâi un interval de timp!")),
      );
      return;
    }
    
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la preluarea datelor: $e")),
      );
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
          // 1. FUNDAL GRADIENT PREMIUM
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF0D1117), const Color(0xFF161B22), const Color(0xFF0D1117)] 
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SIDEBAR (Stânga) ---
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          _buildAssetSelector(isDark),
                          const SizedBox(height: 12),
                          _buildCurrencyCard(isDark), 
                          const SizedBox(height: 12),
                          _buildCalendarCard(isDark), 
                          const SizedBox(height: 24),
                          _buildAnalyzeButton(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // --- ZONA GRAFIC (Dreapta) ---
                    Expanded(
                      child: Container(
                        height: 500,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          // Efect Glassmorphism
                          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.white.withOpacity(0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: loading 
                          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                          : spotsA.isEmpty 
                            ? const Center(
                                child: Text(
                                  "Alege activele și perioada, apoi apasă butonul de calcul.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ChartWidget(
                                spotsA: spotsA, 
                                spotsB: spotsB, 
                                nameA: assetA, 
                                nameB: assetB,
                                statsA: statsA,
                                statsB: statsB,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // --- TABELUL DE STATISTICI ---
                if (!loading && spotsA.isNotEmpty)
                  ComparisonTable(
                    statsA: statsA, 
                    statsB: statsB,
                    nameA: assetA, 
                    nameB: assetB,
                    currency: currency, 
                    rate: rate,
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
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
            color: isDark ? Colors.orangeAccent : Colors.indigo
          ), 
          onPressed: widget.onThemeToggle
        ),
        Text(
          "MARKET ANALYZER PRO", 
          style: TextStyle(
            color: isDark ? Colors.white : Colors.indigo[900], 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2, 
            fontSize: 22
          )
        ),
        IconButton(
          icon: Icon(Icons.share_rounded, color: isDark ? Colors.blueAccent : Colors.indigo),
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

  Widget _buildAssetSelector(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "CONFIGURARE ACTIVE", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.2)
            ),
            const Divider(height: 30),
            _dropDownAsset(assetA, (v) => setState(() => assetA = v!)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15), 
              child: CircleAvatar(
                radius: 18, 
                backgroundColor: Colors.blueAccent, 
                child: Text("VS", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold))
              )
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20), 
      side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: Colors.blueAccent),
          const SizedBox(width: 15),
          const Text("MONEDĂ:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent)),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currency,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1C222D) : Colors.white,
                items: AppConstants.currencies.map((c) => DropdownMenuItem(
                  value: c, 
                  child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold))
                )).toList(),
                onChanged: (v) {
                  setState(() => currency = v!);
                  _fetch(); // Reîncărcăm datele pentru a actualiza rata de schimb
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCalendarCard(bool isDark) {
    // LOGICA PENTRU AFIȘAREA PERIOADEI
    String dateRangeText = "Selectează Intervalul";
    if (range != null) {
      final start = "${range!.start.day}.${range!.start.month}.${range!.start.year}";
      final end = "${range!.end.day}.${range!.end.month}.${range!.end.year}";
      dateRangeText = "$start - $end";
    }

    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_today_rounded, color: Colors.blueAccent),
        ),
        title: const Text(
          "PERIOADĂ ANALIZATĂ", 
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: 1.1)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            dateRangeText, 
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87
            )
          ),
        ),
        onTap: () async {
          final r = await showDateRangePicker(
            context: context, 
            firstDate: DateTime(2022), 
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: isDark ? ThemeData.dark() : ThemeData.light(),
                child: child!,
              );
            },
          );
          if (r != null) { 
            setState(() => range = r); 
            _fetch(); 
          }
        },
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.indigoAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3), 
            blurRadius: 12, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _fetch, 
        child: const Text(
          "CALCULEAZĂ PERFORMANȚA", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)
        ),
      ),
    );
  }

  Widget _dropDownAsset(String current, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        icon: const Icon(Icons.unfold_more_rounded, color: Colors.blueAccent),
        items: AppConstants.assets.keys.map((s) => DropdownMenuItem(
          value: s, 
          child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600))
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}