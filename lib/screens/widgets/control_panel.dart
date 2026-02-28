import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ControlPanel extends StatelessWidget {
  final String assetA, assetB, currency;
  final Function(String?) onA, onB;
  final Function(String) onCurrency;
  final Function() onPickDate;
  final DateTimeRange? range;

  const ControlPanel({super.key, required this.assetA, required this.assetB, required this.onA, required this.onB, required this.range, required this.onPickDate, required this.currency, required this.onCurrency});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _drop(assetA, onA)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("vs")),
              Expanded(child: _drop(assetB, onB)),
            ]),
            const SizedBox(height: 12),
            _currencyToggle(),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPickDate, child: Text(range == null ? "Selectează Interval" : "Perioadă Selectată ✅")),
          ],
        ),
      ),
    );
  }

  Widget _currencyToggle() => SegmentedButton<String>(
    segments: AppConstants.currencies.map((c) => ButtonSegment(value: c, label: Text(c))).toList(),
    selected: {currency},
    onSelectionChanged: (val) => onCurrency(val.first),
  );

  Widget _drop(String val, Function(String?) onCh) => DropdownButtonFormField<String>(
    value: val, items: AppConstants.assets.keys.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 12)))).toList(), onChanged: onCh,
  );
}