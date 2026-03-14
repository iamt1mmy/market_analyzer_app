import 'package:flutter/material.dart';

class AppConstants {
  static const String apiKey = '157d5bded2e04b62a781f636da7e306e';

  // Structura grupata pe categorii pentru Dropdown
  static const Map<String, Map<String, String>> categorizedAssets = {
    'CRYPTO': {
      'Bitcoin (BTC)': 'BTC/USD',
      'Ethereum (ETH)': 'ETH/USD',
      'Solana (SOL)': 'SOL/USD',
      'Cardano (ADA)': 'ADA/USD',
      'Ripple (XRP)': 'XRP/USD',
      'Dogecoin (DOGE)': 'DOGE/USD',
    },
    'TECH STOCKS (USA)': {
      'Apple (AAPL)': 'AAPL',
      'Microsoft (MSFT)': 'MSFT',
      'Google (GOOGL)': 'GOOGL',
      'Amazon (AMZN)': 'AMZN',
      'Tesla (TSLA)': 'TSLA',
      'Nvidia (NVDA)': 'NVDA',
      'Meta (META)': 'META',
      'Netflix (NFLX)': 'NFLX',
    },
    'AUTOMOTIVE & ENERGY': {
      'Ferrari (RACE)': 'RACE',
      'Ford (F)': 'F',
      'General Motors (GM)': 'GM',
      'Exxon Mobil (XOM)': 'XOM',
    },
    'INDICES & COMMODITIES': {
      'Gold (Aur)': 'GOLD',
      'Silver (Argint)': 'SILVER',
    },
    'OTHERS': {
      'Disney (DIS)': 'DIS',
      'Coca-Cola (KO)': 'KO',
      'McDonalds (MCD)': 'MCD',
      'Visa (V)': 'V',
    },
  };

  static Map<String, String> get assets {
    Map<String, String> allAssets = {};
    categorizedAssets.forEach((category, items) {
      allAssets.addAll(items);
    });
    return allAssets;
  }

  static const List<String> currencies = ['USD', 'EUR', 'RON'];
}

class AppColors {
  static const Color primaryIndigo = Color(0xFF1A237E);
  static const Color accentAmber = Colors.amber;
  static final List<Color> bgGradient = [
    const Color(0xFF1A237E),
    const Color(0xFF3949AB),
    const Color(0xFFE1E5E9),
  ];
}