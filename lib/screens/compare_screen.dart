import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../services/currency_service.dart';
import '../services/share_service.dart';
import '../models/chart_data_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'widgets/chart_widget.dart';
import 'widgets/control_panel.dart';
import 'widgets/comparison_table.dart';
import 'widgets/winner_card.dart';

class CompareScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const CompareScreen({super.key, required this.onThemeToggle});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  // Stări pentru selecția activelor și a monedei
  String assetA = 'Bitcoin';
  String assetB = 'Apple';
  String currency = 'USD';
  double rate = 1.0;
  DateTimeRange? range;
  bool loading = false;

  // Datele procesate pentru UI
  List<FlSpot> spotsA = [];
  List<FlSpot> spotsB = [];
  AssetStats statsA = AssetStats.empty();
  AssetStats statsB = AssetStats.empty();

  // Funcția principală de preluare și procesare a datelor
  void _fetch() async {
    if (range == null) return;
    setState(() => loading = true);

    try {
      // 1. Obținem rata de schimb actuală
      rate = await CurrencyService.getRate(currency);

      // 2. Preluăm datele istorice în paralel pentru eficiență
      final data = await Future.wait([
        ApiService.fetchHistory(AppConstants.assets[assetA]!, range!.start),
        ApiService.fetchHistory(AppConstants.assets[assetB]!, range!.start),
      ]);

      setState(() {
        // 3. Procesăm statisticile (Preț start/final/performanță)
        statsA = AssetStats.fromRaw(data[0]);
        statsB = AssetStats.fromRaw(data[1]);

        // 4. Normalizăm punctele pentru grafic (T0 = 0%)
        spotsA = AppHelpers.normalizeData(data[0]);
        spotsB = AppHelpers.normalizeData(data[1]);
        
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eroare la preluarea datelor. Verificați conexiunea sau API Key.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectăm dacă suntem în Dark Mode pentru a ajusta gradientul de fundal
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
                ? [const Color(0xFF0F1218), const Color(0xFF1C222D)] 
                : AppColors.bgGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- HEADERUL MARKET ANALYZER PRO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                      onPressed: widget.onThemeToggle,
                    ),
                    const Text(
                      "MARKET ANALYZER PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: spotsA.isEmpty 
                          ? null 
                          : () => ShareService.shareAnalysis(
                              nameA: assetA,
                              nameB: assetB,
                              statsA: statsA,
                              statsB: statsB,
                              currency: currency,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- PANOU DE CONTROL (Selectoare) ---
                ControlPanel(
                  assetA: assetA,
                  assetB: assetB,
                  currency: currency,
                  range: range,
                  onA: (v) => setState(() => assetA = v!),
                  onB: (v) => setState(() => assetB = v!),
                  onCurrency: (v) {
                    setState(() => currency = v);
                    if (range != null) _fetch();
                  },
                  onPickDate: () async {
                    final r = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (r != null) {
                      setState(() => range = r);
                      _fetch();
                    }
                  },
                ),

                // --- LOADING INDICATOR ---
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),

                // --- ZONA DE REZULTATE (Apare doar după Fetch) ---
                if (!loading && spotsA.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  
                  // Graficul Comparativ
                  ChartWidget(
                    spotsA: spotsA,
                    spotsB: spotsB,
                    nameA: assetA,
                    nameB: assetB,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tabelul cu cifre exacte
                  ComparisonTable(
                    statsA: statsA,
                    statsB: statsB,
                    nameA: assetA,
                    nameB: assetB,
                    currency: currency,
                    rate: rate,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Concluzia (Winner Card)
                  WinnerCard(
                    nameA: assetA,
                    nameB: assetB,
                    pA: statsA.performance,
                    pB: statsB.performance,
                  ),
                  
                  const SizedBox(height: 30),
                ],
                
                // Mesaj de bun venit dacă nu avem date selectate
                if (!loading && spotsA.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text(
                      "Selectează activele și perioada pentru a începe analiza.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}