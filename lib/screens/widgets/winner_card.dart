import 'package:flutter/material.dart';

class WinnerCard extends StatelessWidget {
  final String nameA, nameB;
  final double pA, pB;

  const WinnerCard({super.key, required this.nameA, required this.nameB, required this.pA, required this.pB});

  @override
  Widget build(BuildContext context) {
    bool aW = pA > pB;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: aW ? Colors.orange : Colors.indigo, width: 2)),
      child: Text("🏆 ${aW ? nameA : nameB} a câștigat cu o diferență de ${(pA - pB).abs().toStringAsFixed(2)}%!", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}